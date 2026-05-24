import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_calender/role_permissions.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/cis/cis_dashboard.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/banking/bank_account_list_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/billing/bill_list_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invoice/invoice_new_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/parts_list/product_pick_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/stocks/product_stock_history_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/payroll/vat_summary_page.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/report/profit_loss_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/report/report_menu_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/banking/trial_balance_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/vat_return/vat_return_screen.dart';
import 'package:the_gas_man_app/pages/settings/engineer_settings_page.dart';
import 'package:the_gas_man_app/services/auth_service.dart';
import 'package:the_gas_man_app/services/vat_return_service.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils_class/money.dart';
import '../../new_calender/team_management_screen.dart';
import '../../new_calender/vat_return_new.dart';
import '../../new_invoice_page/account_storage_file.dart';
import '../api_service/auth_token_store.dart';
import 'billing/bill_new_screen.dart';
import 'invite_user/team_screen.dart';
import 'invoice/invoice_list_screen.dart';
import 'auth/invoice_login_screen.dart';
import 'invoice_setting_page.dart';
import 'stocks/product_stock_chart.dart';
import 'vat_return/hmrc_connection_screen.dart';
import 'vat_return/vat_obligation_list.dart';

class InvoiceDashboardScreen extends StatefulWidget {
  const InvoiceDashboardScreen({super.key});

  @override
  State<InvoiceDashboardScreen> createState() => _InvoiceDashboardScreenState();
}

class _InvoiceDashboardScreenState extends State<InvoiceDashboardScreen> {
  final DashboardService _svc = DashboardService();
  bool _loading = true;
  bool? isLoggedIn = false;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = await AuthTokenStore.read();
      isLoggedIn = token != null && token.isNotEmpty;

      _summary = await _svc.getSummary();
    } catch (e) {
      if (mounted) {
        print("Dashboard load failed: $e");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Dashboard load failed: $e")),
        // );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _num(String key) {
    final v = _summary?[key];
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Widget _kpiCard({
    required String title,
    String? subtitle,
    required double value,
    required IconData icon,
    required Function onCardTap,
  }) {
    return InkWell(
      onTap: () {
        onCardTap();
      },
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 13)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          formatMoney(value),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDanger = false, // condition
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: isDanger ? Colors.red : null,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isDanger ? Colors.red : null,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(
            color: isDanger ? Colors.red : Colors.grey, // border color
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_summary != null)
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
// KPI Grid (2 columns)
                      loginButton(),
                      const SizedBox(height: 16),

                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        children: [
                          _kpiCard(
                              title: "Bank Balance",
                              value: _num("bankBalance"),
                              icon: Icons.account_balance,
                              onCardTap: () {
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return BankAccountListScreen();
                                }));
                              }),
                          _kpiCard(
                              title: "Profit (This Month)",
                              value: _num("profitThisMonth"),
                              icon: Icons.trending_up,
                              onCardTap: () {
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return ProfitLossScreen();
                                }));
                              }),
                          _kpiCard(
                              title: "Accounts Receivable",
                              subtitle: "Unpaid invoices",
                              value: _num("accountsReceivable"),
                              icon: Icons.south_west,
                              onCardTap: () {
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return InvoiceNewScreen();
                                }));
                              }),
                          _kpiCard(
                              title: "Accounts Payable",
                              subtitle: "Unpaid bills",
                              value: _num("accountsPayable"),
                              icon: Icons.north_east,
                              onCardTap: () {
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return BillNewScreen();
                                }));
                              }),
                          // _kpiCard(
                          //     title: "Stock Value",
                          //     value: _num("stockValue"),
                          //     icon: Icons.inventory_2,
                          //     onCardTap: () {
                          //       // Navigator.push(context,
                          //       //     CupertinoPageRoute(builder: (context) {
                          //       //   return ProductStockHistoryScreen(product: product);
                          //       // }));
                          //     }),
                          buildStockCard(_summary!),
                          _kpiCard(
                              title: "VAT Payable",
                              subtitle: "Current VAT position",
                              value: _num("vatPayable"),
                              icon: Icons.receipt_long,
                              onCardTap: () {
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return VatSummaryScreen();
                                }));
                              }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _actionButton("Invoices", Icons.receipt, () {
                            //  Navigator.pushNamed(context, "/invoices");
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return InvoiceListScreen();
                            }));
                          }),
                          const SizedBox(width: 10),
                          _actionButton("Bills", Icons.request_quote, () {
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return BillListScreen();
                            }));
                            //  Navigator.pushNamed(context, "/bills");
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _actionButton("Banking", Icons.account_balance_wallet,
                              () {
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return BankAccountListScreen();
                            }));
                            // Navigator.pushNamed(context, "/bank-accounts");
                          }),
                          const SizedBox(width: 10),
                          _actionButton("Reports", Icons.assessment, () {
                            // Navigator.pushNamed(context, "/reports");
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return ReportsMenuScreen();
                            }));
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _actionButton("Company information", Icons.settings,
                              () {
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return CompanyInformationPage(
                                shouldShowAppBar: true,
                                appBarTitle: "Business settings",
                              );
                            }));
                          }),
                          const SizedBox(width: 10),
                          _actionButton("HMRC", Icons.file_copy_outlined,
                              () async {
                            push(HmrcConnectionScreen());
                          }),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _actionButton("Team Members", Icons.people, () async {
                            if(RolePermissions.canManageTeam(userRole!)){
                              push(TeamManagementScreen());
                            }else{
                              showRedSnackbar("You can access team management system");
                            }

                          }),
                          const SizedBox(width: 10),
                          _actionButton(
                              "CIS Module", Icons.account_circle_sharp,
                              () async {
                            push(CisDashboardScreen());
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _actionButton("Vat Return", Icons.money, () async {
                            if (RolePermissions.canSubmitVat(userRole!)) {
                              push(VatReturnNew());
                            } else {
                              showRedSnackbar("You can't submit vat");
                            }
                          }),
                          const SizedBox(width: 10),
                          _actionButton(
                              "Delete Account", Icons.account_circle_outlined,
                              isDanger: true, () async {
                            showDeleteAccountDialog(context);
                            setState(() {});
                          }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text("Tip"),
                          subtitle: const Text(
                            "Reconcile bank transactions to keep your accounts accurate. "
                            "Use Banking → tap a transaction → match to invoice/bill.",
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Padding(
                      padding: EdgeInsetsGeometry.all(20.0),
                      child: loginButton()),
                ),
    );
  }

  Widget loginButton() {
    return InkWell(
      onTap: () async {
        if (isLoggedIn!) {
          await AuthService().logout();
          isLoggedIn = false;
          setState(() {});
        } else {
          await push(InvoiceLoginScreen());
          final token = await AuthTokenStore.read();
          isLoggedIn = token != null && token.isNotEmpty;
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF8C00), // dark orange
              Color(0xFFFFA726), // light orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Container(
          height: 55,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLoggedIn! ? Icons.logout : Icons.login, // 🔥 dynamic icon
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                isLoggedIn! ? "Logout" : "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStockCard(Map data) {
    final stock = data["stockDetails"] ?? {};

    return InkWell(
      onTap: () {
        push(PartListScreen(
          fromScreen: "dashboard",
        ));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Inventory",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("Products", stock["totalProducts"]),
                  _stat("Qty", stock["totalStockQty"]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("Value", "£${stock["totalStockValue"] ?? 0}"),
                  _stat(
                    "Low",
                    stock["lowStockCount"],
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, dynamic value, {Color? color}) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Delete Account"),
                ],
              ),
              content: isLoading
                  ? const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text(
                      "This will permanently delete your account, invoices, and data. This action cannot be undone.",
                    ),
              actions: isLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);

                          try {
                            await AuthService().deleteAccount(onSuccess: () {
                              isLoggedIn = false;
                              Navigator.pop(context);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Account deleted successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() => isLoading = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Delete Permanently"),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
