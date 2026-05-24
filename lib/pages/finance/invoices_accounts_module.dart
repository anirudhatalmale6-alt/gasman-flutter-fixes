// import 'package:flutter/material.dart';
// import 'package:the_gas_man_app/pages/finance/receipt_ocr_page.dart';
//
// import 'expense_list_page.dart';
// import 'invoice_list_page.dart';
// import 'reports_chart_page.dart';
//
//
// class InvoicesAccountsHomePage extends StatelessWidget {
//   const InvoicesAccountsHomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Invoices & Accounts'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // SUMMARY CARD
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'This Year Overview',
//                     style: theme.textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       _SummaryChip(label: 'Income', value: '£0.00'),
//                       _SummaryChip(label: 'Expenses', value: '£0.00'),
//                       _SummaryChip(label: 'Profit', value: '£0.00'),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Your engineer can wire these values to real data later.',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // NAVIGATION TILES
//           _NavTile(
//             icon: Icons.receipt_long_outlined,
//             title: 'Invoices & Quotes',
//             subtitle: 'Create, edit and send PDF invoices/quotes.',
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => const InvoiceListPage(),
//                 ),
//               );
//             },
//           ),
//           _NavTile(
//             icon: Icons.payments_outlined,
//             title: 'Expenses',
//             subtitle: 'Track materials, fuel, tools and other costs.',
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => const ExpensesListPage(),
//                 ),
//               );
//             },
//           ),
//           _NavTile(
//             icon: Icons.document_scanner_outlined,
//             title: 'Scan Receipt (OCR)',
//             subtitle: 'Use the camera or gallery to capture receipts.',
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => const ReceiptOcrPage(),
//                 ),
//               );
//             },
//           ),
//           _NavTile(
//             icon: Icons.bar_chart_outlined,
//             title: 'Reports & Charts',
//             subtitle: 'Monthly income, expenses and VAT summary.',
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => const ReportChartsPage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
// //  all ui classes
//
// class _SummaryChip extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const _SummaryChip({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: theme.textTheme.bodySmall),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// class _NavTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;
//
//   const _NavTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: Icon(icon, color: theme.colorScheme.onSurface),
//         title: Text(title),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: onTap,
//       ),
//     );
//   }
// }




