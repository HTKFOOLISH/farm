import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/field_lot.dart';
import '../../services/database_helper.dart';

class CreateQRScreen extends StatefulWidget {
  const CreateQRScreen({super.key});

  @override
  State<CreateQRScreen> createState() => _CreateQRScreenState();
}

class _CreateQRScreenState extends State<CreateQRScreen> {
  List<FieldLot> _lots = [];
  FieldLot? _selectedLot;

  @override
  void initState() {
    super.initState();
    _loadLots();
  }

  Future<void> _loadLots() async {
    final dbLots = await DatabaseHelper.instance.queryAllLots();
    setState(() {
      _lots = dbLots;
      if (_lots.isNotEmpty) {
        _selectedLot = _lots.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String qrData = _selectedLot != null ? _selectedLot!.lotCode : "NoLot";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo QR Code (TXNG)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _lots.isEmpty
            ? const Center(
          child: Text("Chưa có lô nào. Vui lòng tạo lô trước."),
        )
            : Column(
          children: [
            DropdownButton<FieldLot>(
              value: _selectedLot,
              items: _lots.map((lot) {
                return DropdownMenuItem<FieldLot>(
                  value: lot,
                  child: Text("Lô: ${lot.lotCode}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLot = value;
                });
              },
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            Text("QR Code chứa mã lô: $qrData"),
          ],
        ),
      ),
    );
  }
}
