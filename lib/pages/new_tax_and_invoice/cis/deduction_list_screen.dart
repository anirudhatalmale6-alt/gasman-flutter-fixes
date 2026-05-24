import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/deduction_vm.dart';

class DeductionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeductionVM()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text("Deductions")),
        body: Consumer<DeductionVM>(
          builder: (_, vm, __) {
            return ListView.builder(
              itemCount: vm.list.length,
              itemBuilder: (_, i) {
                final d = vm.list[i];
                return Card(
                  child: ListTile(
                    title: Text(d.description),
                    subtitle: Text("£${d.grossAmount}"),
                    trailing: Text("£${d.netPayment}"),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}