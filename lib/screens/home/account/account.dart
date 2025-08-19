import 'package:flutter/material.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:protect_our_forest/screens/home/account/update_info/update_info.dart';
import 'package:protect_our_forest/models/user.dart';
import '../../../services/auth_service.dart';
import '../../home_not_login/home_not_login.dart';

class AccountScreen extends StatefulWidget {
  final User? user;

  const AccountScreen({super.key, this.user});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      await authService.logout();
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeNotLoginScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tài khoản',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: homeBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: ForestBackground(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage(
                          'assets/image/home/account_image.png',
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 6,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xff2DE409),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _user?.userName ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    _user?.email ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateInfoScreen(user: _user),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonPrimaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Cập nhật thông tin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: Colors.black,
                    thickness: 0.5,
                    indent: 40,
                    endIndent: 40,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      children: [
                        ProfileMenuWidget(
                          title: 'Cài đặt',
                          icon: Icons.settings,
                          onPress: () {},
                        ),
                        ProfileMenuWidget(
                          title: 'Tài liệu hướng dẫn',
                          icon: Icons.description,
                          onPress: () {},
                        ),
                        ProfileMenuWidget(
                          title: 'Lịch sử hoạt động',
                          icon: Icons.history,
                          onPress: () {},
                        ),
                        const Divider(),
                        ProfileMenuWidget(
                          title: 'Đổi mật khẩu',
                          icon: Icons.lock,
                          onPress: () {},
                        ),
                        ProfileMenuWidget(
                          title: 'Đăng xuất',
                          icon: Icons.logout,
                          onPress: _logout,
                          iconColor: Colors.red,
                          textColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.iconColor = const Color(0xFF386EE4),
    this.textColor = Colors.black,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      contentPadding: const EdgeInsets.symmetric(vertical: 1),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(Icons.chevron_right, size: 20.0, color: Colors.grey),
      ),
    );
  }
}
