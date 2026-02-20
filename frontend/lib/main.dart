import 'package:flutter/material.dart';

import 'package:schedula/pages/home_page.dart';
import 'package:schedula/pages/login_page.dart';
import 'package:schedula/pages/my_bookings_page.dart';
import 'package:schedula/pages/my_activities_page.dart';
import 'package:schedula/pages/profile_page.dart';
import 'package:schedula/services/user_service.dart';

import 'package:schedula/widgets/schedula_appbar.dart';
import 'package:schedula/widgets/schedula_bottom_navigationbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Schedula(),
    );
  }
}

class Schedula extends StatefulWidget {
  const Schedula({super.key});

  @override
  SchedulaState createState() => SchedulaState();
}

class SchedulaState extends State<Schedula> {
  int currentIndexOfPages = 0;
  final UserService userService = UserService();
  bool isLoggedIn = false;
  bool isLoading = true;
  int userId = -1;
  Widget? extraPage;

  @override
  void initState() {
    super.initState();
    _initializeLoginStatus();
  }

  /// 🔥 Metodo sicuro: l'async non contiene setState
  Future<void> checkLoginStatus() async {
    isLoggedIn = await userService.isLoggedIn();
    isLoading = false;
    final id = await userService.getUserId();
    userId = id != null ? int.parse(id) : -1;
  }

  /// 🔥 Questo metodo richiama l’async e poi aggiorna la UI in sicurezza
  void _initializeLoginStatus() async {
    await checkLoginStatus();
    if (mounted) {
      setState(() {});
    }
  }

  /// 🔥 Login
  void onLoginSuccess() async {
    currentIndexOfPages = 3; // vai al profilo
    await checkLoginStatus();
    if (mounted) {
      setState(() {});
    }
  }

  /// 🔥 Logout
  void onLogout() async {
    await userService.logout();
    currentIndexOfPages = 0; // torna in home
    await checkLoginStatus();
    if (mounted) {
      setState(() {});
    }
  }

  Widget getPageForIndex(int index) {
    switch (index) {
      case 0:
        return HomePage(
          onOpenExtraPage: openExtraPage,
          onCloseExtraPage: closeExtraPage,
          userId: userId,
        );
      case 1:
        return MyBookingsPage(userId: userId);
      case 2:
        return MyActivitiesPage(
          userId: userId,
          onOpenExtraPage: openExtraPage,
          onCloseExtraPage: closeExtraPage,
        );
      case 3:
        return isLoggedIn
            ? ProfilePage(userId: userId, onLogout: onLogout, onNavigateToTab: onTabTapped,)
            : LoginPage(onLoginSuccess: onLoginSuccess);
      default:
        return HomePage(
          onOpenExtraPage: openExtraPage,
          onCloseExtraPage: closeExtraPage,
          userId: userId,
        );
    }
  }

  void onTabTapped(int index) {
    currentIndexOfPages = index;
    setState(() {});
  }

  void openExtraPage(Widget page) {
    extraPage = page;
    setState(() {});
  }

  void closeExtraPage() {
    extraPage = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 🔥 Per evitare flicker mentre controlliamo login
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const SchedulaAppBar(),
      body: extraPage ?? getPageForIndex(currentIndexOfPages),
      bottomNavigationBar: extraPage == null ? SchedulaBottomNagivationBar(
        currentIndexOfPages: currentIndexOfPages,
        onTabTapped: onTabTapped,
      ) : null
    );
  }
}
