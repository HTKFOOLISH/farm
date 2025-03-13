import 'package:flutter/material.dart';
import '../../models/field_lot.dart';
import '../../services/database_helper.dart';
import 'activity_screen.dart';

class FieldLotScreen extends StatefulWidget {
  const FieldLotScreen({super.key});

  @override
  State<FieldLotScreen> createState() => _FieldLotScreenState();
}

class _FieldLotScreenState extends State<FieldLotScreen> {
  List<FieldLot> _lots = [];

  @override
  void initState() {
    super.initState();
    _loadLots();
  }

  Future<void> _loadLots() async {
    final dbLots = await DatabaseHelper.instance.queryAllLots();
    setState(() {
      _lots = dbLots;
    });
  }

  Future<void> _addLotDialog() async {
    final lotCodeController = TextEditingController();
    final areaController = TextEditingController();
    final statusController = TextEditingController(text: 'Đang gieo');
    DateTime? sowDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm Lô/Trại"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: lotCodeController,
                  decoration: const InputDecoration(labelText: "Mã lô"),
                ),
                TextField(
                  controller: areaController,
                  decoration: const InputDecoration(labelText: "Diện tích (m²)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: "Tình trạng"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sowDate == null
                            ? "Chưa chọn ngày gieo"
                            : "Ngày gieo: ${sowDate!.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          sowDate = picked;
                          // Cập nhật dialog
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Kiểm tra dữ liệu
                if (lotCodeController.text.isEmpty || sowDate == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập đủ thông tin (mã lô, ngày gieo)."),
                    ),
                  );
                  return;
                }
                try {
                  final lot = FieldLot(
                    lotCode: lotCodeController.text,
                    area: double.tryParse(areaController.text) ?? 0.0,
                    status: statusController.text,
                    sowDate: sowDate!,
                  );
                  await DatabaseHelper.instance.insertLot(lot);
                  Navigator.pop(context);
                  _loadLots();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi: $e"),
                    ),
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
  }

  Future<void> _deleteLot(int id) async {
    await DatabaseHelper.instance.deleteLot(id);
    _loadLots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lô/Trại (NKTT)'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[200],
      body: _lots.isEmpty
          ? const Center(
        child: Text(
          "Chưa có lô/trại nào được thêm.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: _lots.length,
        itemBuilder: (context, index) {
          final lot = _lots[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              leading: const Icon(
                Icons.agriculture,
                color: Colors.green,
                size: 32,
              ),
              title: Text(
                "Lô: ${lot.lotCode}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Tình trạng: ${lot.status}\nDiện tích: ${lot.area} m²\nNgày gieo: ${lot.sowDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(fontSize: 14),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 28,
                ),
                onPressed: () {
                  _deleteLot(lot.id!);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityScreen(lot: lot),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLotDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

