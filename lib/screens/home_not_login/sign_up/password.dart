import 'package:flutter/material.dart';
import 'package:protect_our_forest/screens/home_not_login/sign_up/more_info.dart';
import '../../../config/background.dart';
import '../../../config/colors.dart';

class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({super.key, required this.email});

  @override
  PasswordScreenState createState() => PasswordScreenState();
}

class PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  bool isPasswordVisible = false;
  bool isPasswordConfirmVisible = false;

  bool isLoading = false;

  Future<void> _verifyPassword() async {
    if (isLoading) return;

    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();

    if (password.isEmpty || passwordConfirm.isEmpty) {
      _showError('Vui lòng nhập mật khẩu và xác nhận mật khẩu.');
      return;
    }

    if (password != passwordConfirm) {
      _showError('Mật khẩu và xác nhận mật khẩu không khớp.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (password.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự.');
      }

      if (password == passwordConfirm) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreInfoScreen(email: widget.email, password: password)),
        );
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: backgroundNotLogin, // Sử dụng ảnh nền đã định nghĩa
          ),

          // Overlay màu mờ để dễ đọc chữ
          Positioned.fill(child: Container(color: Colors.black.withAlpha(77))),

          // Nội dung chính
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Nút quay lại
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Logo
                Image.asset(
                  'assets/image/home/logo_square.png', // icon app
                  height: 259,
                ),

                const SizedBox(height: 10),
                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 20),
                      child: const Text(
                        'Đăng ký',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 5),
                      child: const Text(
                        'Vui lòng nhập mật khẩu tạo \nmới.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Mô tả
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                    decoration: BoxDecoration(
                      color: white.withAlpha(40),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mật khẩu',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInputField(
                              hintText: 'Nhập mật khẩu',
                              controller: passwordController,
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Xác nhận mật khẩu',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInputField(
                              hintText: 'Nhập lại mật khẩu',
                              controller: passwordConfirmController,
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _verifyPassword,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: buttonPrimaryColor,
                              foregroundColor: black,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ), // Nút Đăng nhập
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
