// import 'package:flutter/material.dart';
// import 'package:the_gas_man_app/pages/finance/common_models/invoice.dart';
//
// import 'invoice_edit_page.dart';
//
// class InvoiceListPage extends StatelessWidget {
//   const InvoiceListPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: load real invoices from storage.
//     final dummyInvoices = <Invoice>[
//       Invoice(
//         id: '1',
//         documentNumber: 'INV-001',
//         customerName: 'Example Customer',
//         total: 0.0,
//         date: DateTime.now(),
//         status: InvoiceStatus.draft, items: [],
//       ),
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Invoices & Quotes'),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: dummyInvoices.length,
//         itemBuilder: (context, index) {
//           final invoice = dummyInvoices[index];
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               title: Text(invoice.documentNumber),
//               subtitle: Text(
//                 '${invoice.customerName} • ${_formatDate(invoice.date)}',
//               ),
//               trailing: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text('£${invoice.total.toStringAsFixed(2)}'),
//                   const SizedBox(height: 4),
//                   _InvoiceStatusChip(status: invoice.status),
//                 ],
//               ),
//               onTap: () {
//                 // Navigator.of(context).push(
//                 //   MaterialPageRoute(
//                 //     builder: (_) => InvoiceEditPage(existing: invoice),
//                 //   ),
//                 // );
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //     builder: (_) => const InvoiceEditPage(),
//           //   ),
//           // );
//         },
//         icon: const Icon(Icons.add),
//         label: const Text('New Invoice'),
//       ),
//     );
//   }
// }
//
// String _formatDate(DateTime date) {
//   return '${date.day.toString().padLeft(2, '0')}/'
//       '${date.month.toString().padLeft(2, '0')}/'
//       '${date.year}';
// }
//
// class _InvoiceStatusChip extends StatelessWidget {
//   final InvoiceStatus status;
//
//   const _InvoiceStatusChip({required this.status});
//
//   @override
//   Widget build(BuildContext context) {
//     String label;
//     switch (status) {
//       case InvoiceStatus.draft:
//         label = 'Draft';
//         break;
//       case InvoiceStatus.sent:
//         label = 'Sent';
//         break;
//       case InvoiceStatus.paid:
//         label = 'Paid';
//         break;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: Colors.grey.shade400),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(fontSize: 11),
//       ),
//     );
//   }
// }
//
// String _fmtDate(DateTime d) =>
//     '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//
//
