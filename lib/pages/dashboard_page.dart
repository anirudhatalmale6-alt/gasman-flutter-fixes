import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/pages/calendar_page.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/login_page.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_home_page.dart';
import 'package:the_gas_man_app/pages/new_calender/role_permissions.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/auth/invoice_login_screen.dart';
import 'package:the_gas_man_app/pages/settings/engineer_settings_page.dart';
import 'package:the_gas_man_app/pages/tools/gas_rate_page.dart';
import 'package:the_gas_man_app/pages/tools/pipe_sizing_page.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_model.dart';
import '../main.dart';
import 'find_merchants_page.dart';
import 'new_calender/calender_dashboard_page.dart';
import 'new_calender/upcoming_jobs_screen.dart';
import 'new_certificate/certificate_home_page.dart';
import 'new_invoice_page/pages/account_home_page.dart';
import 'new_tax_and_invoice/invoice_and_tax_main_screen.dart';
import 'radiator/radiator_calculator_page.dart';
import 'termsandcondition/terms_and_condition_page.dart';
import 'tools/latest_pipe_sizing_code.dart';
import 'tools/ventilation_page_new.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();

    final items = <_Item>[
      _Item('Certificates', Icons.assignment_turned_in_outlined,
          () => _go(context, const CertificatesHomePage())),
      _Item('Accounts & Tax', Icons.request_quote_outlined, () {
        if (!app.isLoggedIn!) {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return InvoiceLoginScreen();
          }));
        } else {
          if (RolePermissions.canAccessAccounting(userRole!)) {
            Navigator.push(context, CupertinoPageRoute(builder: (context) {
              return InvoiceAndTaxMainScreen();
            }));
          } else {
            ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
              SnackBar(
                content: Text("You can't access Tax and Accounting system"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }),
      _Item(
          'MarketPlace',
          Icons.shop,
          () => _go(
              context,
              !app.isMarketPlaceUserLoggedIn!
                  ? LoginPage()
                  : const MarketplaceHomePage())),

      // _Item(
      //     'Calendar',
      //     Icons.calendar_month,
      //     () => _go(
      //         context,
      //         !app.isLoggedIn!
      //             ? const InvoiceLoginScreen(
      //                 fromScreen: "calender",
      //               )
      //             : const CalenderDashboardPage(
      //                 userRole: "owner",
      //               ))),

      _Item(
          'Job Management',
          Icons.calendar_month,
          (){
            if (!app.isLoggedIn!) {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return InvoiceLoginScreen(fromScreen: "calender",);
              }));
            } else {
              if (RolePermissions.canAccessJobs(userRole!)) {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return CalenderDashboardPage();
                }));
              } else {
                ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
                  SnackBar(
                    content: Text("You can't access Job Management System"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }),

      _Item('Gas Rate', Icons.speed_outlined,
          () => _go(context, const GasRatePage())),
      _Item('Pipe Sizing', Icons.architecture_outlined,
          () => _go(context, const LatestGasPipeSizingPage())),
      _Item('Ventilation', Icons.air_outlined,
          () => _go(context, const VentilationCalculatorPage())),
      _Item('Radiator Calculator', Icons.calculate_outlined,
          () => _go(context, const RadiatorCalculatorPage())),
      _Item('Find Merchants', Icons.store_mall_directory_outlined,
          () => _go(context, const FindMerchantsPage())),

      _Item('Basic Accounting', Icons.account_balance,
          () => _go(context, const AccountsHomePage())),
      _Item('Terms and Conditions \n Contact Us', Icons.tab,
          () => _go(context, const TermsAndConditionsPage())),
      _Item(
          'Company Information',
          Icons.settings,
          () => _go(
              context,
              !app.isLoggedIn!
                  ? const InvoiceLoginScreen(
                      fromScreen: "company",
                    )
                  : const CompanyInformationPage(
                      shouldShowAppBar: true,
                    ))),
      // _Item('Latest Pipe Sizing Code', Icons.architecture_outlined,
      //         () => _go(context, const LatestGasPipeSizingPage())),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              if (!app.isLoggedIn!) {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return InvoiceLoginScreen(
                    fromScreen: "calender",
                  );
                }));
              } else {
                if (RolePermissions.canAccessJobs(userRole!)) {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) {
                    return UpcomingJobsScreen();
                  }));
                } else {
                  ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
                    SnackBar(
                      content: Text("You can't access Job Management System"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Upcoming Jobs',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 6),
                          Text('Add jobs in Calendar; reminders supported.',
                              style: TextStyle(color: Colors.white70)),
                        ]),
                  ),
                  color: Colors.orange),
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: items.length,
            itemBuilder: (c, i) {
              final item = items[i];
              return InkWell(
                onTap: item.onTap,
                child: Card(
                  elevation: 0,
                  color: Theme.of(c).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(item.icon, size: 38, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ]),
                  ),
                ),
              );
            },
          ),
          InkWell(
            onTap: () async {
              await launchUrl(Uri.parse("https://embrasspeerless.co.uk/"));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text('Sponsored by Embrass Peerless',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

class _Item {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _Item(this.title, this.icon, this.onTap);
}
