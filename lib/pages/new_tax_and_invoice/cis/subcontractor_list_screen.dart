import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_edit_sub_contractor.dart';
import 'subcontractor_details_screen.dart';
import 'view_models/sub_cintractor_vm.dart';

class SubcontractorListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubcontractorVM()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text("Subcontractors")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => SubcontractorFormScreen()));
          },
          child: Icon(Icons.add),
        ),
        body: Consumer<SubcontractorVM>(
          builder: (_, vm, __) {

              if(vm.isLoading){
                return Center(child: CircularProgressIndicator(),);
              }
              if(vm.list.isEmpty){
                return Center(
                  child: Text("No subcontractor found"),
                );
              }

            return ListView.builder(
              itemCount: vm.list.length,
              itemBuilder: (_, i) {
                final s = vm.list[i];
                return Card(
                  child: ListTile(
                    title: Text(s.name),
                    subtitle: Text("UTR: ${s.utr}"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${s.deductionRate}%"),
                        Text(s.verificationStatus),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubcontractorDetailScreen(s.id),
                      ),
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