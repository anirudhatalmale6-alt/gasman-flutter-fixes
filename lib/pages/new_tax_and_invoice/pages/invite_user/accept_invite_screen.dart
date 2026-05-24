import 'package:flutter/material.dart';
import '../../../../services/invite_services.dart';

class AcceptInviteScreen extends StatefulWidget {
  final String? inviteCode;

  const AcceptInviteScreen({super.key, this.inviteCode});

  @override
  State<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends State<AcceptInviteScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> acceptInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await InviteService().acceptInvite(
        inviteCode: inviteCodeController.text,
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invite accepted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.inviteCode != null) {
      inviteCodeController.text = widget.inviteCode!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accept Invite"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mail_outline,
                        size: 60, color: Colors.blue),
                    const SizedBox(height: 16),

                    const Text(
                      "Join Invitation",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: inviteCodeController,
                      decoration: InputDecoration(
                        labelText: "Invite Code",
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Invite Code is required";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// Password Field
                    TextFormField(
                      controller: passController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 characters required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    /// Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : acceptInvite,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Accept Invite",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
