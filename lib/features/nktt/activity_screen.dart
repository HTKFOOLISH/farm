import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/field_lot.dart';
import '../../models/farming_log_entry.dart';
import '../../services/database_helper.dart';

class ActivityScreen extends StatefulWidget {
  final FieldLot lot;
  const ActivityScreen({super.key, required this.lot});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<FarmingLogEntry> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (widget.lot.id == null) return;
    final logs = await DatabaseHelper.instance.queryLogsByLot(widget.lot.id!);
    setState(() {
      _activities = logs;
    });
  }

  Future<void> _addActivityDialog() async {
    final activityTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? activityDate;
    String? pickedImagePath; // Đường dẫn file ảnh sau khi chọn/chụp

    final ImagePicker _picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) {
        // Sử dụng StatefulBuilder để cập nhật trạng thái bên trong dialog
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setStateDialog) {
            // Hàm chụp ảnh từ camera
            Future<void> _pickImageFromCamera() async {
              try {
                final XFile? pickedFile =
                await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setStateDialog(() {
                    pickedImagePath = pickedFile.path;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi chụp ảnh: $e")),
                );
              }
            }

            // Hàm chọn ảnh từ thư viện
            Future<void> _pickImageFromGallery() async {
              try {
                final XFile? pickedFile =
                await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setStateDialog(() {
                    pickedImagePath = pickedFile.path;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi chọn ảnh: $e")),
                );
              }
            }

            return AlertDialog(
              title: const Text("Thêm hoạt động"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: activityTypeController,
                      decoration: const InputDecoration(
                          labelText: "Loại hoạt động (gieo, bón phân,...)"),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activityDate == null
                                ? "Chưa chọn ngày"
                                : "Ngày: ${activityDate!.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                activityDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Mô tả"),
                    ),
                    TextField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: "Chi phí"),
                      keyboardType: TextInputType.number,
                    ),
                    // Nút để chụp ảnh hoặc chọn ảnh từ thư viện
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Chụp ảnh"),
                          onPressed: _pickImageFromCamera,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo),
                          label: const Text("Chọn ảnh"),
                          onPressed: _pickImageFromGallery,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Hiển thị preview ảnh nếu đã chọn
                    if (pickedImagePath != null)
                      Container(
                        height: 150,
                        width: 150,
                        child: Image.file(
                          File(pickedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: "Ghi chú"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (activityTypeController.text.isEmpty ||
                        activityDate == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Vui lòng nhập đủ loại hoạt động và ngày."),
                        ),
                      );
                      return;
                    }
                    try {
                      final entry = FarmingLogEntry(
                        lotId: widget.lot.id!,
                        activityType: activityTypeController.text,
                        activityDate: activityDate!,
                        description: descriptionController.text,
                        cost: double.tryParse(costController.text) ?? 0.0,
                        images: pickedImagePath ?? "",
                        notes: notesController.text,
                      );
                      await DatabaseHelper.instance.insertLog(entry);
                      Navigator.pop(context);
                      _loadActivities();
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e")),
                      );
                    }
                  },
                  child: const Text("Lưu"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lot = widget.lot;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoạt động - Lô ${lot.lotCode}'),
      ),
      body: ListView.builder(
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final act = _activities[index];
          return ListTile(
            title: Text(act.activityType),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${act.activityDate.toLocal().toString().split(' ')[0]} - ${act.description}",
                ),
                Text("Chi phí: ${act.cost.toStringAsFixed(2)} VND"),
                Text("Ghi chú: ${act.notes}"),
                if (act.images.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Image.file(File(act.images)),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.file(
                        File(act.images),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivityDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
