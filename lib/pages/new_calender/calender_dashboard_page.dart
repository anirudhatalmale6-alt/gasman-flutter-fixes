import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/pages/new_calender/dispatch_live_board_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/engineer_management_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/job_calendar_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/job_scheduler_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/today_jobs_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import '../../services/chat_service.dart';
import '../new_tax_and_invoice/api_service/auth_token_store.dart';
import '../new_tax_and_invoice/pages/auth/invoice_login_screen.dart';
import 'chat/chat_list_screen.dart';
import 'role_permissions.dart';

class CalenderDashboardPage extends StatefulWidget {
  const CalenderDashboardPage({super.key});

  @override
  State<CalenderDashboardPage> createState() => _CalenderDashboardPageState();
}

class _CalenderDashboardPageState extends State<CalenderDashboardPage> {
  final ChatService _chatService = ChatService();
  bool _hasUnread = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _checkUnread();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkUnread();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUnread() async {
    if (!mounted) return;
    final hasUnread = await _chatService.hasUnreadMessages();
    if (mounted && hasUnread != _hasUnread) {
      setState(() => _hasUnread = hasUnread);
    }
  }

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
          if (RolePermissions.canManageTeam(userRole!)) ...[
            const Divider(height: 1),
            ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.group),
                  if (_hasUnread)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: const Text("Team Chat"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "New",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () async {
                await push(ChatListScreen());
                await _chatService.markRead();
                _checkUnread();
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
