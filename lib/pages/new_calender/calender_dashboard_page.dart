import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/pages/new_calender/dispatch_live_board_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/engineer_management_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/job_calendar_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/job_scheduler_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/today_jobs_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import '../new_tax_and_invoice/api_service/auth_token_store.dart';
import '../new_tax_and_invoice/pages/auth/invoice_login_screen.dart';
import 'chat/chat_list_screen.dart';
import 'role_permissions.dart';

class CalenderDashboardPage extends StatelessWidget {
  const CalenderDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Management"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Job Calendar"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              push(JobCalendarScreen());
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_view_week),
            title: const Text("Job Scheduler"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              push(JobSchedulerScreen());
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.today),
            title: const Text("Today's Jobs"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              push(TodayJobsScreen());
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text("Engineers"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              push(EngineerManagementScreen());
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text("Engineer Live Board"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              push(DispatchLiveBoardScreen());
            },
          ),

          // if (RolePermissions.canAccessAccounting(userRole!)) ...[
          //   const Divider(height: 1),
          //   ListTile(
          //     leading: const Icon(
          //       Icons.assessment,
          //     ),
          //     title: const Text("Reports"),
          //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //     onTap: () {
          //       push(ReportsMenuScreen());
          //     },
          //   )
          // ],
          if (RolePermissions.canManageTeam(userRole!)) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.group,
              ),
              title: const Text("Team Chat"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                push(ChatListScreen());
              },
            )
          ],
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.logout,
            ),
            title: const Text("LogOut"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final token = await AuthTokenStore.clear();
              Provider.of<AppModel>(context, listen: false).isLoggedIn = false;
              await push(InvoiceLoginScreen(
                fromScreen: "calender",
              ));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/jobs/new",
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
