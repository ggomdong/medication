import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../constants/sizes.dart';
import '../views/widgets/nav_tab.dart';
import '../views/home_screen.dart';
import '../views/profile_screen.dart';
import '../views/qr_scan_screen.dart';
import '../views/calendar_screen.dart';
import '../utils.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key, required this.tab});

  final String tab;

  @override
  MainNavigationScreenState createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<String> _tabs = ["home", "qr", "calendar", "shop", "profile"];

  late int _selectedIndex =
      _tabs.contains(widget.tab) ? _tabs.indexOf(widget.tab) : 0;

  //최초 로딩시 라우팅을 적용함. url을 직접 쳤을때 대응을 위함
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentTab = GoRouterState.of(context).matchedLocation.split('/')[1];
    if (_tabs.contains(currentTab)) {
      _selectedIndex = _tabs.indexOf(currentTab);
    } else {
      _selectedIndex = 0;
    }
  }

  void _onTap(int index) {
    if (index == 1) {
      // QR 화면은 1회성 화면이므로 별도 push로 열고, 하단바 index는 그대로 유지
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QRScanScreen()),
      );
      return;
    }

    context.go("/${_tabs[index]}");
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          _selectedIndex == 0 || isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Offstage(offstage: _selectedIndex != 0, child: const HomeScreen()),
          // Offstage(offstage: _selectedIndex != 1, child: QRScanScreen()),
          Offstage(offstage: _selectedIndex != 2, child: CalendarScreen()),
          Offstage(
            offstage: _selectedIndex != 3,
            child: Center(child: Text("포인트샵")),
          ),
          Offstage(offstage: _selectedIndex != 4, child: ProfileScreen()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2C2C) : Color(0xFFE0F0FD),
          border: Border(
            top: BorderSide(color: Colors.black, width: Sizes.size2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: Sizes.size12,
            right: Sizes.size12,
            top: Sizes.size24,
            bottom: Sizes.size20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NavTab(
                isSelected: _selectedIndex == 0,
                icon: FontAwesomeIcons.house,
                selectedIcon: FontAwesomeIcons.house,
                onTap: () => _onTap(0),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                isSelected: _selectedIndex == 1,
                icon: FontAwesomeIcons.qrcode,
                selectedIcon: FontAwesomeIcons.qrcode,
                onTap: () => _onTap(1),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                isSelected: _selectedIndex == 2,
                icon: FontAwesomeIcons.solidCalendar,
                selectedIcon: FontAwesomeIcons.solidCalendar,
                onTap: () => _onTap(2),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                isSelected: _selectedIndex == 3,
                icon: FontAwesomeIcons.cartShopping,
                selectedIcon: FontAwesomeIcons.cartShopping,
                onTap: () => _onTap(3),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                isSelected: _selectedIndex == 4,
                icon: FontAwesomeIcons.solidUser,
                selectedIcon: FontAwesomeIcons.solidUser,
                onTap: () => _onTap(4),
                selectedIndex: _selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
