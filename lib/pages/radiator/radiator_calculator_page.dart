import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// GAS MAN colours
const Color kTeal = Color(0xFF008080);
const Color kAmber = Color(0xFFFFB000);
const Color kDark = Color(0xFF0B2E2E);
const Color kLightBg = Color(0xFFF9F9F9);

class RadiatorCalculatorPage extends StatefulWidget {
  const RadiatorCalculatorPage({super.key});

  @override
  State<RadiatorCalculatorPage> createState() => _RadiatorCalculatorPageState();
}

class _RadiatorCalculatorPageState extends State<RadiatorCalculatorPage> {
  final List<_RoomConfig> _rooms = [];
  Uint8List? _generatedPdfBytes;

  @override
  void initState() {
    super.initState();
    _addRoom(); // start with one room
  }

  void _addRoom() {
    setState(() {
      _rooms.add(_RoomConfig(name: 'Room ${_rooms.length + 1}'));
    });
  }

  void _removeRoom(int index) {
    if (_rooms.length == 1) return; // always keep at least one
    setState(() {
      _rooms.removeAt(index);
    });
  }

  double get _totalBtu {
    return _rooms.fold(0.0, (sum, r) => sum + r.calculatedBtu);
  }

  int get _totalBtuRounded {
    return _roundToNearest50(_totalBtu).toInt();
  }

  int _roundToNearest50(double value) {
    if (value <= 0) return 0;
    return (value / 50).ceil() * 50;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBg,
      appBar: AppBar(
        backgroundColor: kTeal,
        title: const Text('Radiator BTU Calculator'),
        actions: [
          IconButton(
            onPressed: _viewPdf,
            tooltip: 'View PDF',
            icon: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
            ),
          ),

          IconButton(
            onPressed: _sharePdf,
            tooltip: 'Share PDF',
            icon: const Icon(
              Icons.email,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // TOTAL SUMMARY CARD
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Heat Requirement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_totalBtuRounded} BTU/hr',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kTeal,
                    ),
                  ),
                  if (_totalBtu > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '(Exact: ${_totalBtu.toStringAsFixed(0)} BTU/hr)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'This is the approximate total BTU output needed for all rooms combined.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return _buildRoomCard(room, index);
              },
            ),
          ),

          // ADD ROOM BUTTON
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _addRoom,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Another Room',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(_RoomConfig room, int index) {
    final roomBtu = room.calculatedBtu;
    final roomRounded = _roundToNearest50(roomBtu);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Room name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    controller: room.nameController,
                    onChanged: (v) => room.name = v.trim(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: index == 0 ? Colors.grey : Colors.redAccent,
                  onPressed: index == 0 ? null : () => _removeRoom(index),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // DIMENSIONS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Length (m)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        setState(() => room.length = _toDouble(v)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Width (m)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        setState(() => room.width = _toDouble(v)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Height (m)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        setState(() => room.height = _toDouble(v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RoomTypeDropdown(
              value: room.roomType,
              onChanged: (v) =>
                  setState(() => room.roomType = v ?? room.roomType),
            ),
            const SizedBox(height: 10),
            _InsulationDropdown(
              value: room.insulation,
              onChanged: (v) =>
                  setState(() => room.insulation = v ?? room.insulation),
            ),

            // DROPDOWNS: ROOM TYPE + INSULATION
            // Row(
            //   children: [
            //     Expanded(
            //       child: _RoomTypeDropdown(
            //         value: room.roomType,
            //         onChanged: (v) =>
            //             setState(() => room.roomType = v ?? room.roomType),
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: _InsulationDropdown(
            //         value: room.insulation,
            //         onChanged: (v) =>
            //             setState(() => room.insulation = v ?? room.insulation),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 8),

            // CHECKBOXES: WINDOWS / DOORS / NORTH
            Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Large windows',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: room.largeWindows,
                  onChanged: (v) =>
                      setState(() => room.largeWindows = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Patio / French doors',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: room.patioDoors,
                  onChanged: (v) =>
                      setState(() => room.patioDoors = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'North-facing room',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: room.northFacing,
                  onChanged: (v) =>
                      setState(() => room.northFacing = v ?? false),
                ),
              ],
            ),

            const Divider(),

            // ROOM RESULT
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${room.name.isEmpty ? 'Room ${index + 1}' : room.name} BTU Requirement',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${roomRounded.toStringAsFixed(0)} BTU/hr',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTeal,
                    ),
                  ),
                  if (roomBtu > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '(Exact: ${roomBtu.toStringAsFixed(0)} BTU/hr)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _toDouble(String input) {
    return double.tryParse(input.replaceAll(',', '.')) ?? 0.0;
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text(
              'Radiator BTU Calculation Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Total Heat Requirement',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    '${_totalBtuRounded} BTU/hr',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    'Exact: ${_totalBtu.toStringAsFixed(0)} BTU/hr',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'Room Breakdown',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
              ),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    _pdfCell('Room', bold: true),
                    _pdfCell('Dimensions', bold: true),
                    _pdfCell('Room Type', bold: true),
                    _pdfCell('Insulation', bold: true),
                    _pdfCell('BTU/hr', bold: true),
                  ],
                ),

                ..._rooms.map((room) {
                  return pw.TableRow(
                    children: [
                      _pdfCell(
                        room.name.isEmpty ? 'Room' : room.name,
                      ),

                      _pdfCell(
                        '${room.length}m × '
                            '${room.width}m × '
                            '${room.height}m',
                      ),

                      _pdfCell(room.roomType.label),

                      _pdfCell(room.insulation.label),

                      _pdfCell(
                        _roundToNearest50(
                          room.calculatedBtu,
                        ).toString(),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              'This calculation is an estimate only. '
                  'Always verify final radiator sizing and system design.',
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ];
        },
      ),
    );

    _generatedPdfBytes = await pdf.save();
  }

  pw.Widget _pdfCell(
      String text, {
        bool bold = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
          bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
    );
  }

  Future<void> _viewPdf() async {
    await _generatePdf();

    if (_generatedPdfBytes == null) return;

    await Printing.layoutPdf(
      onLayout: (format) async => _generatedPdfBytes!,
    );
  }

  Future<void> _sharePdf() async {
    await _generatePdf();

    if (_generatedPdfBytes == null) return;

    await Printing.sharePdf(
      bytes: _generatedPdfBytes!,
      filename: 'radiator_btu_report.pdf',
    );
  }
}

/// Internal room model
class _RoomConfig {
  String name;
  final TextEditingController nameController;
  double length; // m
  double width; // m
  double height; // m
  RoomType roomType;
  InsulationLevel insulation;
  bool largeWindows;
  bool patioDoors;
  bool northFacing;

  _RoomConfig({
    required this.name,
    this.length = 0,
    this.width = 0,
    this.height = 2.4,
    this.roomType = RoomType.livingRoom,
    this.insulation = InsulationLevel.average,
    this.largeWindows = false,
    this.patioDoors = false,
    this.northFacing = false,
  }) : nameController = TextEditingController(text: name);

  double get volumeM3 => length * width * height;

  /// Approx BTU formula (BestHeating-style):
  /// baseBTU = volume(m3) * 153
  /// then apply room type, insulation & extras
  double get calculatedBtu {
    if (volumeM3 <= 0) return 0;
    double base = volumeM3 * 153.0;

    double roomFactor = roomType.factor;
    double insulationFactor = insulation.factor;

    double extraPercent = 0.0;
    if (largeWindows) extraPercent += 0.15; // +15%
    if (patioDoors) extraPercent += 0.10;   // +10%
    if (northFacing) extraPercent += 0.10;  // +10%

    double result = base * roomFactor * insulationFactor * (1 + extraPercent);
    return result;
  }
}

/// Room types & multipliers (BestHeating-style)
enum RoomType {
  livingRoom,
  diningRoom,
  kitchen,
  bedroom,
  bathroom,
  conservatory,
  hallwayLanding,
  other,
}

extension RoomTypeExt on RoomType {
  String get label {
    switch (this) {
      case RoomType.livingRoom:
        return 'Living room';
      case RoomType.diningRoom:
        return 'Dining room';
      case RoomType.kitchen:
        return 'Kitchen';
      case RoomType.bedroom:
        return 'Bedroom';
      case RoomType.bathroom:
        return 'Bathroom';
      case RoomType.conservatory:
        return 'Conservatory';
      case RoomType.hallwayLanding:
        return 'Hallway / Landing';
      case RoomType.other:
        return 'Other';
    }
  }

  double get factor {
    switch (this) {
      case RoomType.livingRoom:
        return 1.0;
      case RoomType.diningRoom:
        return 1.0;
      case RoomType.kitchen:
        return 0.9;
      case RoomType.bedroom:
        return 0.9;
      case RoomType.bathroom:
        return 1.1;
      case RoomType.conservatory:
        return 1.5;
      case RoomType.hallwayLanding:
        return 0.8;
      case RoomType.other:
        return 1.0;
    }
  }
}

/// Insulation levels (BestHeating-style)
enum InsulationLevel {
  poor,
  average,
  good,
  excellent,
}

extension InsulationLevelExt on InsulationLevel {
  String get label {
    switch (this) {
      case InsulationLevel.poor:
        return 'Poor insulation';
      case InsulationLevel.average:
        return 'Average insulation';
      case InsulationLevel.good:
        return 'Good insulation';
      case InsulationLevel.excellent:
        return 'Excellent insulation';
    }
  }

  double get factor {
    switch (this) {
      case InsulationLevel.poor:
        return 1.2;
      case InsulationLevel.average:
        return 1.0;
      case InsulationLevel.good:
        return 0.8;
      case InsulationLevel.excellent:
        return 0.6;
    }
  }
}

/// Dropdown for room type
class _RoomTypeDropdown extends StatelessWidget {
  final RoomType value;
  final ValueChanged<RoomType?> onChanged;

  const _RoomTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RoomType>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Room type',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: RoomType.values.map((r) {
        return DropdownMenuItem(
          value: r,
          child: Text(r.label),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// Dropdown for insulation
class _InsulationDropdown extends StatelessWidget {
  final InsulationLevel value;
  final ValueChanged<InsulationLevel?> onChanged;

  const _InsulationDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<InsulationLevel>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Insulation Level',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: InsulationLevel.values.map((i) {
        return DropdownMenuItem(
          value: i,
          child: Text(i.label,overflow: TextOverflow.ellipsis,),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}