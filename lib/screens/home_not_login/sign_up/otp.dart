import 'package:flutter/material.dart';
import 'package:protect_our_forest/screens/home_not_login/sign_up/password.dart';
import 'package:protect_our_forest/services/auth_service.dart';
import '../../../config/background.dart';
import '../../../config/colors.dart';

class OTPScreen extends StatefulWidget {
  final String email;

  const OTPScreen({super.key, required this.email});

  @override
  OTPScreenState createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> {
  final TextEditingController OTPController = TextEditingController();
  bool isLoading = false;

  final authService = AuthService();

  Future<void> _requestOTP() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });
    try {
      await authService.requestOTP(widget.email);
      if (!mounted) return;
      _showSuccess('OTP đã được gửi lại qua email.');
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (isLoading) return;

    final otp = OTPController.text.trim();

    if (otp.isEmpty) {
      _showError('Vui lòng nhập OTP của bạn.');
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      await authService.verifyOTP(OTPController.text.trim(), widget.email);
      if (!mounted) return;
      _showSuccess('OTP đã được xác thực thành công.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
                        'Mã xác thực đã được gửi tới \nemail của bạn.',
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
                              'OTP',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // _buildInputField(
                            //   hintText: 'Nhập email',
                            //   controller: emailController,
                            //   icon: Icons.email,
                            // ),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: OTPController,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nhập mã OTP',
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Bạn không nhận được?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                ),
                                onPressed: isLoading ? null : _requestOTP,
                                child: const Text(
                                  'Gửi lại mã',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _verifyOTP,
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
                              'Xác thực',
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

  // Widget _buildInputField({
  //   required String hintText,
  //   required TextEditingController controller,
  //   required IconData icon,
  //   bool isPassword = false,
  // }) {
  //   return Container(
  //     alignment: Alignment.centerLeft,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     child: TextField(
  //       textAlignVertical: TextAlignVertical.center,
  //       controller: controller,
  //       obscureText: isPassword && !isPasswordVisible,
  //       decoration: InputDecoration(
  //         border: InputBorder.none,
  //         hintText: hintText,
  //         prefixIcon: Icon(icon),
  //         suffixIcon: isPassword
  //             ? IconButton(
  //                 icon: Icon(
  //                   isPasswordVisible ? Icons.visibility : Icons.visibility_off,
  //                 ),
  //                 onPressed: () {
  //                   setState(() {
  //                     isPasswordVisible = !isPasswordVisible;
  //                   });
  //                 },
  //               )
  //             : null,
  //       ),
  //     ),
  //   );
  // }
}
