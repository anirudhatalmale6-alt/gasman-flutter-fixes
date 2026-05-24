import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import '../../../utils_class/app_pdf_documents.dart';
import '../common_models/warning_notice_record.dart';
import '../common_ui/company_logo.dart';
import '../common_ui/date_picker_row.dart';
import '../common_ui/input.dart';
import '../common_ui/section_card.dart';
import '../common_ui/switch_row.dart';
import '../common_ui/warning_item_card.dart';
import 'warning_notice_repository.dart';

class NewWarningNoticePage extends StatefulWidget {
  final WarningNoticeRecord? existing;

  const NewWarningNoticePage({super.key, this.existing});

  @override
  State<NewWarningNoticePage> createState() => _NewWarningNoticePageState();
}

class _NewWarningNoticePageState extends State<NewWarningNoticePage> {
  late WarningNoticeRecord record;
  final repo = WarningNoticeRepository.instance;
  bool? isLoadingdata = false;

  @override
  void initState() {
    super.initState();
    record = widget.existing ??
        WarningNoticeRecord(
          id: UniqueKey().toString(),
          noticeNumber: "WN-00001",
        );

    Future.delayed(Duration.zero, () {
      setCompanyDetails();
      getNextCertificateNumber();
    });
  }

  void setCompanyDetails() async {
    AccountingSettings companySettings = AccountStorage().settings;
    if (companySettings != null) {
      record.engineerName = companySettings.engineerName;
      record.engineerCompanyName = companySettings.businessName;
      record.engineerCompanyAddress = companySettings.businessAddress;
      record.engineerGasSafeNo = companySettings.gasSafeNumber;
      record.engineerCompanyPhone = companySettings.businessPhone;
      record.engineerCompanyEmail = companySettings.businessEmail;
      record.engineerCompanyPostcode = companySettings.postalCode;
      setState(() {});
    }
  }

  void loadData() async {
    Future.delayed(Duration(seconds: 1), () async {
      isLoadingdata = true;
      setState(() {});
      WarningNoticeRecord? prefWarningRecord = await repo.loadRecords();
      if (prefWarningRecord != null) {
        record = prefWarningRecord;
        isLoadingdata = false;
        setState(() {});
      }
    });
  }

  Future<String> getNextCertificateNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('warning_records');

    if (data == null) {
      return "WN-00001"; // first record
    }

    final List decoded = jsonDecode(data);

    if (decoded.isEmpty) {
      return "WN-00001";
    }

    /// 🔥 Get last record
    final last = decoded.last;

    final lastNumberStr = last['noticeNumber'] ?? "WN-00000";

    /// Extract numeric part
    final numberPart = lastNumberStr.toString().replaceAll("WN-", "");

    int number = int.tryParse(numberPart) ?? 0;

    number++; // increment

    /// Format with leading zeros
    final newNumber = number.toString().padLeft(5, '0');
    record.noticeNumber = "WN-$newNumber";
    // _certificateNumberController.text = "WN-"+newNumber;

    return "WN-$newNumber";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warning / Defect Notice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              _onPdfPressed(record);
            },
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: () {
              _onEmailPressed(record);
              // TODO: Generate PDF + email
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Notice Information',
            child: Text('Notice #: ${record.noticeNumber}'),
          ),

          const SizedBox(height: 12),

          /// PROPERTY DETAILS
          SectionCard(
            title: 'Property Details',
            child: Column(
              children: [
                Input(
                  label: 'Property address',
                  value: record.propertyAddress,
                  onChanged: (v) => record.propertyAddress = v,
                  maxLines: 2,
                ),
                Input(
                  label: 'Postcode',
                  value: record.postcode,
                  onChanged: (v) => record.postcode = v,
                ),
                Input(
                  label: 'Occupier / Tenant (optional)',
                  value: record.occupierName,
                  onChanged: (v) => record.occupierName = v,
                ),
                Input(
                  label: 'Landlord (optional)',
                  value: record.landlordName,
                  onChanged: (v) => record.landlordName = v,
                ),
                Input(
                  label: 'Phone',
                  value: record.phone,
                  onChanged: (v) => record.phone = v,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// DATE & TIME
          SectionCard(
            title: 'Date / Time',
            child: Column(
              children: [
                DatePickerRow(
                  label: 'Date issued',
                  date: record.dateIssued,
                  onChanged: (d) => setState(() => record.dateIssued = d),
                ),
                Input(
                  label: 'Time issued',
                  value: record.timeIssued,
                  onChanged: (v) => record.timeIssued = v,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ITEMS
          SectionCard(
            title: 'Unsafe Appliance / Installation',
            trailing: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              onPressed: () {
                setState(() {
                  record.items.add(WarningApplianceEntry());
                });
              },
            ),
            child: Column(
              children: [
                for (int i = 0; i < record.items.length; i++)
                  WarningItemCard(
                    entry: record.items[i],
                    index: i,
                    onDelete: () {
                      setState(() => record.items.removeAt(i));
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          SectionCard(
            title: 'Actions Taken',
            child: Column(
              children: [
                SwitchRow(
                  label: 'Appliance shut off',
                  value: record.applianceShutOff,
                  onChanged: (v) => setState(() => record.applianceShutOff = v),
                ),
                SwitchRow(
                  label: 'Disconnected',
                  value: record.disconnected,
                  onChanged: (v) => setState(() => record.disconnected = v),
                ),
                SwitchRow(
                  label: 'Warning label applied',
                  value: record.warningLabelApplied,
                  onChanged: (v) =>
                      setState(() => record.warningLabelApplied = v),
                ),
                SwitchRow(
                  label: 'Gas supply capped/isolated',
                  value: record.supplyCapped,
                  onChanged: (v) => setState(() => record.supplyCapped = v),
                ),
                Input(
                  label: 'Additional actions / comments',
                  value: record.additionalActions,
                  onChanged: (v) => record.additionalActions = v,
                  maxLines: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// RESPONSIBLE PERSON
          SectionCard(
            title: 'Responsible Person',
            child: Column(
              children: [
                Input(
                  label: 'Name',
                  value: record.responsiblePersonName,
                  onChanged: (v) => record.responsiblePersonName = v,
                ),
                Input(
                  label: 'Role (tenant / landlord / owner)',
                  value: record.responsiblePersonRole,
                  onChanged: (v) => record.responsiblePersonRole = v,
                ),
                SwitchRow(
                  label: 'Responsible person signed',
                  value: record.responsiblePersonSigned,
                  onChanged: (v) =>
                      setState(() => record.responsiblePersonSigned = v),
                ),
                SwitchRow(
                  label: 'Refused to sign',
                  value: record.refusedToSign,
                  onChanged: (v) => setState(() => record.refusedToSign = v),
                ),
                if (record.refusedToSign)
                  Input(
                    label: 'Refusal notes',
                    value: record.refusalNotes,
                    onChanged: (v) => record.refusalNotes = v,
                    maxLines: 2,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ENGINEER DETAILS
          SectionCard(
            title: 'Engineer Details',
            child: Column(
              children: [
                CompanyLogo(),
                const SizedBox(height: 10.0,),
                Input(
                  label: 'Engineer name',
                  value: record.engineerName,
                  onChanged: (v) => record.engineerName = v,
                ),
                Input(
                  label: 'Gas Safe number',
                  value: record.engineerGasSafeNo,
                  onChanged: (v) => record.engineerGasSafeNo = v,
                ),
                const Divider(),
                Input(
                  label: 'Company name',
                  value: record.engineerCompanyName,
                  onChanged: (v) => record.engineerCompanyName = v,
                ),
                Input(
                  label: 'Company address',
                  value: record.engineerCompanyAddress,
                  onChanged: (v) => record.engineerCompanyAddress = v,
                  maxLines: 2,
                ),
                Input(
                  label: 'Postcode',
                  value: record.engineerCompanyPostcode,
                  onChanged: (v) => record.engineerCompanyPostcode = v,
                ),
                Input(
                  label: 'Phone',
                  value: record.engineerCompanyPhone,
                  onChanged: (v) => record.engineerCompanyPhone = v,
                ),
                Input(
                  label: 'Email',
                  value: record.engineerCompanyEmail,
                  onChanged: (v) => record.engineerCompanyEmail = v,
                ),
                const SizedBox(height: 12),
                SwitchRow(
                  label: 'Engineer signed',
                  value: record.engineerSigned,
                  onChanged: (v) => setState(() => record.engineerSigned = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              repo.upsert(record);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Warning notice saved')),
              );
            },
            child: const Text('Save Notice'),
          ),
        ],
      ),
    );
  }

  // generate pdf

  Future<void> _onPdfPressed(WarningNoticeRecord data) async {
    final bytes = await generateGasSafetyCertificatePdf(data);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
  Future<void> _onEmailPressed(WarningNoticeRecord data) async {

    final bytes = await generateGasSafetyCertificatePdf(data);
    final file = await _writePdfToTempFile(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Warning Notice ${data.noticeNumber}',
      text:
      'Please find attached the Warning Notice Safety Check for ${data.propertyAddress}.',
    );
  }
  Future<File> _writePdfToTempFile(Uint8List bytes,
      {String fileName = 'warning_notice.pdf'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Uint8List> generateGasSafetyCertificatePdf(
    WarningNoticeRecord data,
  ) async {

   final pdf = AppPdfDocument();
    final accountStorage = AccountStorage();
    await accountStorage.load();
    final s = accountStorage.settings;
   pw.MemoryImage? logo;
   if(s.logoPath != null && s.logoPath!.isNotEmpty){
     final Uint8List imageBytes = await File(s.logoPath!).readAsBytes();
     logo = pw.MemoryImage(imageBytes);
   }
   final icGasLogo = await imageFromAssetBundle(
     'assets/ic_gas_safe.png',
   );


    final gasSafeLogoBytes = await rootBundle.load('assets/ic_app_logo.png');
    final gasSafeLogo = pw.MemoryImage(gasSafeLogoBytes.buffer.asUint8List());

   final ic_gas_extra = await imageFromAssetBundle(
     'assets/ic_gas_safe.png',
   );

    final title = 'Warning/Defect Notice';

    final primaryTeal = PdfColor.fromInt(0xFF3C6E6A);
    final lightBg = PdfColor.fromInt(0xFFF5F8F7);

    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final labelStyle = pw.TextStyle(
      fontSize: 9,
      color: PdfColors.grey800,
    );

    final valueStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );

    pw.Widget borderedBox(String label, String value, {double height = 28}) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(3),
          border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
        ),
        height: height,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: labelStyle),
            pw.Text(value, style: valueStyle, maxLines: 1),
          ],
        ),
      );
    }


    pw.Widget yesNoBox(String label, bool? value) {
      String text;
      if (value == null) {
        text = 'N/A';
      } else {
        text = value ? 'Yes' : 'No';
      }
      final color = value == null
          ? PdfColors.grey600
          : (value ? PdfColors.green800 : PdfColors.red800);
      return pw.Container(
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(3),
          border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: labelStyle),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                text,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Header
          pw.Container(
            decoration: pw.BoxDecoration(
              color: primaryTeal,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            padding: const pw.EdgeInsets.all(10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Gas Man', style: headerStyle),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if(logo != null)...[
                      pw.Row(
                          children: [
                            pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child:  pw.Image(ic_gas_extra, width: 60, height: 60)
                            ),
                            pw.SizedBox(width: 8),
                            pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child:  pw.Image(logo, width: 60, height: 60)
                            )
                          ]
                      ),
                      pw.SizedBox(height: 8)
                    ],
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'Notice No # ${data.noticeNumber}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: primaryTeal,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      height: 24,
                      width: 48,
                      child: pw.Image(gasSafeLogo, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          // LANDLORD / PROPERTY DETAILS
          pw.Container(
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Landlord & Property Details',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox(
                              'Landlord / Owner name', data.landlordName),
                          pw.SizedBox(height: 4),
                          borderedBox('Phone', data.phone),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox(
                              'Tenant (if applicable)', data.occupierName),
                          pw.SizedBox(height: 4),
                          borderedBox('Property address', data.propertyAddress,
                              height: 34),
                          pw.SizedBox(height: 4),
                          borderedBox('Property postcode', data.postcode),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Container(
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Date/Time',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox('Date issued',
                              DateFormat("dd/MM/yyyy").format(data.dateIssued)),
                          pw.SizedBox(height: 4),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox('Time issued', data.timeIssued),
                          pw.SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // APPLIANCES TABLE
          pw.Container(
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey500, width: 0.6),
            ),
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Appliance Details',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside:
                        pw.BorderSide(color: PdfColors.grey500, width: 0.25),
                    outside:
                        pw.BorderSide(color: PdfColors.grey500, width: 0.25),
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(16), // #
                    1: pw.FlexColumnWidth(1.2),
                    2: pw.FlexColumnWidth(1.2),
                    3: pw.FlexColumnWidth(1.2),
                    4: pw.FlexColumnWidth(1.1),
                    5: pw.FlexColumnWidth(1.0),
                    6: pw.FlexColumnWidth(1.0),
                    7: pw.FlexColumnWidth(1.0),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: lightBg),
                      children: [
                        _headerCell('#'),
                        _headerCell('Serial Number'),
                        _headerCell('Type'),
                        _headerCell('Make'),
                        _headerCell('Model'),
                        _headerCell('Location'),
                        _headerCell('Defect details'),
                      ],
                    ),
                    ...data.items.asMap().entries.map((entry) {
                      final i = entry.key + 1;
                      final a = entry.value;
                      return pw.TableRow(
                        children: [
                          _cell(i.toString()),
                          _cell(a.serialNumber),
                          _cell(a.type),
                          _cell(a.make),
                          _cell(a.model),
                          _cell(a.location),
                          _cell(a.defectDetails),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // APPLIANCE + FLUE + PIPEWORK CHECKS
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Action Taken',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryTeal,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      yesNoBox('Appliance shut off', data.applianceShutOff),
                      pw.SizedBox(height: 3),
                      yesNoBox('Disconnected', data.disconnected),
                      pw.SizedBox(height: 3),
                      yesNoBox(
                          'Warning label applied', data.warningLabelApplied),
                      pw.SizedBox(height: 3),
                      yesNoBox('Gas Supply capped/isolated', data.supplyCapped),
                      pw.SizedBox(height: 3),
                      borderedBox('Additional actions/comments', data.postcode),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Responsible Person',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryTeal,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      borderedBox('Name', data.responsiblePersonName),
                      pw.SizedBox(height: 3),
                      borderedBox('Role', data.responsiblePersonRole),
                      pw.SizedBox(height: 3),
                      yesNoBox('Responsible person signed',
                          data.responsiblePersonSigned),
                      pw.SizedBox(height: 3),
                      yesNoBox('Refused to sign', data.refusedToSign),
                      pw.SizedBox(height: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 8),

          // ENGINEER / COMPANY DETAILS
          pw.Container(
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Engineer / Company Details',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox('Engineer name', data.engineerName),
                          pw.SizedBox(height: 4),
                          borderedBox('Gas Safe registration no.',
                              data.engineerGasSafeNo),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox('Company name', data.engineerCompanyName),
                          pw.SizedBox(height: 4),
                          borderedBox(
                              'Company address', data.engineerCompanyAddress,
                              height: 34),
                          pw.SizedBox(height: 4),
                          borderedBox('Postcode', data.engineerCompanyPostcode),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          borderedBox('Phone', data.engineerCompanyPhone),
                          pw.SizedBox(height: 4),
                          borderedBox('Email', data.engineerCompanyEmail),
                        ],
                      ),
                    ),
                    yesNoBox('Refused to sign', data.refusedToSign),
                    pw.SizedBox(height: 3),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 6),

          // FOOTER
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              '${data.engineerCompanyName} ${data.engineerCompanyAddress} ${data.engineerCompanyPostcode} Tel: ${data.engineerCompanyPhone} Gas Safe Reg: ${data.engineerGasSafeNo}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

// Helper cells
  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8),
        textAlign: pw.TextAlign.center,
        maxLines: 3,
      ),
    );
  }

  pw.Widget _multiLineBox(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
        pw.Container(
          width: double.infinity,
          height: 45,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(3),
            border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
          ),
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }
}
