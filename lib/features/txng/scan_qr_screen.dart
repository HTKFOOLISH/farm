import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/field_lot.dart';
import '../../models/farming_log_entry.dart';
import '../../services/database_helper.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  String scannedData = "";
  FieldLot? _lot;
  List<FarmingLogEntry> _activities = [];

  MobileScannerController controller = MobileScannerController();

  Future<void> _fetchLotByCode(String lotCode) async {
    // Lấy danh sách lô
    final lots = await DatabaseHelper.instance.queryAllLots();
    // Tìm lô có lotCode khớp
    final matchedLot = lots.firstWhere(
          (l) => l.lotCode == lotCode,
      orElse: () => FieldLot(
        lotCode: 'NotFound',
        area: 0,
        status: 'NotFound',
        sowDate: DateTime.now(),
      ),
    );
    if (matchedLot.id != null) {
      final logs = await DatabaseHelper.instance.queryLogsByLot(matchedLot.id!);
      setState(() {
        _lot = matchedLot;
        _activities = logs;
      });
    } else {
      setState(() {
        _lot = null;
        _activities = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR Code (TXNG)'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Phần quét camera với overlay viền chỉ định khu vực quét
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      final code = barcodes.first.rawValue!;
                      // Dừng quét sau khi nhận được mã
                      controller.stop();
                      setState(() {
                        scannedData = code;
                      });
                      _fetchLotByCode(code);
                    }
                  },
                ),
                // Overlay viền chỉ định khu vực quét
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần hiển thị kết quả
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: SingleChildScrollView(
                child: scannedData.isEmpty
                    ? Center(
                  child: Text(
                    "Chưa có dữ liệu quét",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
                    : _lot == null || _lot!.lotCode == 'NotFound'
                    ? Center(
                  child: Text(
                    "Không tìm thấy lô có mã: $scannedData",
                    style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                )
                    : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mã lô: ${_lot!.lotCode}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Diện tích: ${_lot!.area} m²",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tình trạng: ${_lot!.status}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Ngày gieo: ${_lot!.sowDate.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        if (_lot!.harvestDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Ngày thu hoạch: ${_lot!.harvestDate}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        const Divider(height: 32, thickness: 1),
                        const Text(
                          "Nhật ký hoạt động:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._activities.map((act) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                act.activityType,
                                style: const TextStyle(fontSize: 18),
                              ),
                              subtitle: Text(
                                "${act.activityDate.toLocal().toString().split(' ')[0]} - ${act.description}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
