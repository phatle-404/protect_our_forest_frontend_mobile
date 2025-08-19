import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protect_our_forest/models/user.dart';
import 'package:protect_our_forest/screens/home/farmland/farm_land.dart';
import 'package:protect_our_forest/screens/home/map/map.dart';
import 'package:protect_our_forest/screens/home/weather/weather.dart';
import 'account/account.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({this.user, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  // Future<void> _loadUserData() async {
  //   try {
  //     final user = await UserDataService.loadUserData(_user?.userId ?? '');
  //     setState(() {
  //       _user = user;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MapScreen(user: _user),
      LocationScreen(user: _user),
      WeatherScreen(),
      AccountScreen(user: _user),
    ];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE8F5E9), Color(0xFFA5D6A7)],
          ),
        ),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar:
          // Nền trắng bo góc
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),

            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(icon: Icons.map, label: 'Bản đồ', index: 0),
                _navItem(
                  icon: Icons.agriculture,
                  label: 'Vùng canh tác',
                  index: 1,
                ),
                _navItem(icon: Icons.wb_sunny, label: 'Thời tiết', index: 2),
                _navItem(icon: Icons.person, label: 'Tài khoản', index: 3),
              ],
            ),
          ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          height: 60,
          decoration: isSelected
              ? BoxDecoration(
                  color: Color(0xFF1b3b3a),
                  borderRadius: BorderRadius.circular(40),
                )
              : null,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.black,
                  size: 28,
                ),
                if (!isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
