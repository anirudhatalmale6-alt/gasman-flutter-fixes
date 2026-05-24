import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/main.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/login_page.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/market_place_terms.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_service.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import 'all_tabs/browse_items_page.dart';
import 'all_tabs/messages_page.dart';
import 'all_tabs/my_listing_page.dart';
import 'all_tabs/saved_items_page.dart';
import 'all_tabs/sell_item_page.dart';

const kAppGreen = Color(0xFF476E69);

const kCardRadius = 20.0;

BoxDecoration appTile() => BoxDecoration(
      color: kAppGreen,
      borderRadius: BorderRadius.circular(kCardRadius),
    );

BoxDecoration orangeAppTile() => BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(kCardRadius),
    );

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final List<MenuItemConfig> menuItems = [
    MenuItemConfig(
      title: "Login",
      icon: Icons.account_box_outlined,
      screen: LoginPage(),
    ),
    MenuItemConfig(
      title: "Browse Items",
      icon: Icons.store,
      screen: const BrowseItemsPage(),
    ),
    MenuItemConfig(
      title: "Sell an Item",
      icon: Icons.add_box_outlined,
      screen: const SellItemPage(),
      requiresLogin: true,
    ),
    MenuItemConfig(
      title: "My Listings",
      icon: Icons.list_alt,
      screen: const MyListingsPage(),
      requiresLogin: true,
    ),
    MenuItemConfig(
      title: "Saved Items",
      icon: Icons.bookmark_outline,
      screen: const SavedItemsPage(),
      requiresLogin: true,
    ),
    MenuItemConfig(
      title: "Messages",
      icon: Icons.chat,
      screen: const MessagesPage(),
      requiresLogin: true,
    )
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateList();
  }

  void updateList() {
    final marketPlaceInstance = MarketplaceService.instance;
    if (marketPlaceInstance.authUser != null) {
      menuItems[0] = MenuItemConfig(
        title: "Logout",
        icon: Icons.logout,
        screen: LoginPage(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppGreen,
        title: const Text("Marketplace"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                children: List.generate(menuItems.length, (index) {
                  final marketServiceInstance = MarketplaceService.instance;
                  return _MenuTile(
                      menuItems[index].title, menuItems[index].icon,
                      isLoginButton: index == 0, () async {
                    if (index == 0 && marketServiceInstance.authUser != null) {
                      await marketServiceInstance.logoutUser();
                      menuItems[0] = MenuItemConfig(
                        title: "Login",
                        icon: Icons.account_box_outlined,
                        screen: LoginPage(),
                      );
                      ScaffoldMessenger.of(mainKey!.currentContext!)
                          .showSnackBar(
                        SnackBar(content: Text("Logout successfully!")),
                      );
                      setState(() {});
                    } else if (index == 0 &&
                        marketServiceInstance.authUser == null) {
                      await Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return LoginPage();
                      }));
                      if (marketServiceInstance.authUser != null) {
                        ScaffoldMessenger.of(mainKey!.currentContext!)
                            .showSnackBar(
                          SnackBar(content: Text("Login successfully!")),
                        );
                        menuItems[0] = MenuItemConfig(
                          title: "Logout",
                          icon: Icons.logout,
                          screen: LoginPage(),
                        );
                        setState(() {});
                      }
                    } else if (menuItems[index].requiresLogin &&
                        marketServiceInstance.authUser == null) {
                      await Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return LoginPage();
                      }));
                      if (marketServiceInstance.authUser != null) {
                        ScaffoldMessenger.of(mainKey!.currentContext!)
                            .showSnackBar(
                          SnackBar(content: Text("Login successfully!")),
                        );
                        menuItems[0] = MenuItemConfig(
                          title: "Logout",
                          icon: Icons.logout,
                          screen: LoginPage(),
                        );
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(mainKey!.currentContext!)
                            .showSnackBar(
                          SnackBar(content: Text("Auth user is null")),
                        );
                      }
                    } else {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) {
                        return menuItems[index].screen;
                      }));
                    }
                  });
                }),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  push(MarketPlaceTermsConditionsScreen());
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text('Terms and condition',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final bool isLoginButton;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile(this.title, this.icon, this.onTap,
      {super.key, this.isLoginButton = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: isLoginButton ? orangeAppTile() : appTile(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemConfig {
  final String title;
  final IconData icon;
  final Widget screen;
  final bool requiresLogin;

  const MenuItemConfig({
    required this.title,
    required this.icon,
    required this.screen,
    this.requiresLogin = false,
  });
}
