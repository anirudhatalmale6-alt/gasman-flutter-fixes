import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/company_settings.dart';

class ContactUsPage extends StatefulWidget {
  static const route = '/contact_us';

  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Website",
                style: kSectionTitleStyle,
              ),
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse("https://www.gasmanbusiness.co.uk"));
                },
                child: Container(
                    height: 40.0,
                    child: Center(child: Text("www.gasmanbusiness.co.uk"))),
              ),
              SizedBox(
                height: 12.0,
              ),
              Text(
                "Email",
                style: kSectionTitleStyle,
              ),
              InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(
                        "mailto:info@gasmanbusiness.co.uk?subject=''&body=''"));
                  },
                  child: Container(
                      height: 40.0,
                      child: Center(child: Text("info@gasmanbusiness.co.uk")))),
              SizedBox(
                height: 60.0,
              ),
            ]),
      ),
    );
  }
}
