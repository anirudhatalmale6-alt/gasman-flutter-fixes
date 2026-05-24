import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/sub_cintractor_vm.dart';

class SubcontractorFormScreen extends StatefulWidget {
  @override
  State<SubcontractorFormScreen> createState() => _State();
}

class _State extends State<SubcontractorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final utrController = TextEditingController();
  final nationalInsuranceNumbr = TextEditingController();
  final taxCodeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    utrController.dispose();
    nationalInsuranceNumbr.dispose();
    taxCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubcontractorVM(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Subcontractor"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: companyController,
                    decoration: const InputDecoration(
                      labelText: "Company Details",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: utrController,
                    decoration: const InputDecoration(
                      labelText: "UTR",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nationalInsuranceNumbr,
                    decoration: const InputDecoration(
                      labelText: "National Insurance Number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextFormField(
                    controller: taxCodeController,
                    decoration: const InputDecoration(
                      labelText: "TaxCode",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Consumer<SubcontractorVM>(
                    builder: (context, vm, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await vm.add({
                              "name": nameController.text,
                              "address": addressController.text,
                              "company_details": companyController.text,
                              "phone": phoneController.text,
                              "email": emailController.text,
                              "utr": utrController.text,
                              "national_insurance_number": nationalInsuranceNumbr.text,
                              "tax_code": taxCodeController.text,
                            });

                            Navigator.pop(context);
                          },
                          child: const Text("Save"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}