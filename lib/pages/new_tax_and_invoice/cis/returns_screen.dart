import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/returns_vm.dart';

class ReturnsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReturnsVM()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text("CIS Returns")),
        body: Consumer<ReturnsVM>(
          builder: (_, vm, __) {
            if(vm.isLoading){
              return Center(child: CircularProgressIndicator(),);
            }
            if(vm.months.isEmpty){
              return Center(
                child: Text("No returns found"),
              );
            }

            return ListView.builder(
              itemCount: vm.months.length,
              itemBuilder: (_, i) {
                final m = vm.months[i];
                return Card(
                  child: ListTile(
                    title: Text(m.month),
                    subtitle: Text(m.status),
                    trailing: ElevatedButton(
                      onPressed: () => vm.open(m.month),
                      child: Text("View"),
                    ),
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