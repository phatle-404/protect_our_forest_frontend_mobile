import 'package:flutter/material.dart';
import 'package:protect_our_forest/screens/home_not_login/login/login.dart';
import 'package:protect_our_forest/screens/home_not_login/sign_up/otp.dart';
import 'package:protect_our_forest/services/auth_service.dart';
import '../../../config/background.dart';
import '../../../config/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  final authService = AuthService();

  Future<void> _requestOTP() async {
    if (isLoading) return;

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showError('Vui lòng nhập email của bạn.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.requestOTP(email);
      if (!mounted) return;
      _showSuccess('OTP đã được gửi đến email của bạn.');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPScreen(email: emailController.text.trim())),
      );
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
                        'Tạo tài khoản của bạn. Nhập \nemail của bạn.',
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
                              'Email',
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
                                controller: emailController,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nhập email',
                                  prefixIcon: Icon(Icons.email),
                                  suffixIcon: null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Bạn cần xác nhận lại email của mình sau đó.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                            onPressed: isLoading ? null :_requestOTP,
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

                        const SizedBox(height: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Bạn đã có tài khoản?\nĐăng nhập',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
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
