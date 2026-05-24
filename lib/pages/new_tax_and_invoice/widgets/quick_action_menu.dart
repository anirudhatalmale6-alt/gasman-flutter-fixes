import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_calender/role_permissions.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/customer/customer_list_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/estimates/estimate_list_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/supplier/supplier_list_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../employee/employee_list_screen.dart';
import '../pages/banking/bank_account_list_screen.dart';
import '../pages/billing/bill_new_screen.dart';
import '../pages/invoice/invoice_new_screen.dart';
import '../pages/payroll/payroll_run_list_screen.dart';

class QuickActionMenu extends StatelessWidget {
  final Function(Widget screen) onSelected;

  const QuickActionMenu({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("New Invoice"),
            onTap: () => onSelected(InvoiceNewScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("New Estimate"),
            onTap: () => onSelected(EstimateListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("New Customer"),
            onTap: () => onSelected(CustomerListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text("New Bill"),
            onTap: () => onSelected(BillNewScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("New Supplier"),
            onTap: () => onSelected(SupplierListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("New Bank Transaction"),
            onTap: () => onSelected(BankAccountListScreen()),
          ),
          ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("New Payroll Run"),
              onTap: () {
                if (RolePermissions.canAccessPayroll(userRole!)) {
                  onSelected(PayrollRunListScreen());
                } else {
                  showRedSnackbar("Yu cant access payroll management systems");
                }
              }),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("New Employee"),
            onTap: () => onSelected(EmployeeListScreen()),
          ),
        ],
      ),
    );
  }
}
