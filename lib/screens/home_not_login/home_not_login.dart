import 'package:flutter/material.dart';
import '../../config/background.dart';
import '../../config/colors.dart';
import 'login/login.dart';
import 'sign_up/sign_up.dart';

class HomeNotLoginScreen extends StatelessWidget {
  const HomeNotLoginScreen({super.key});

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
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 125, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/image/home/logo_square.png', // icon app
                    height: 128,
                  ),

                  // Tiêu đề
                  const Text(
                    'Protect\nOur \nForest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Merriweather',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Mô tả
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: white.withAlpha(40),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Bảo vệ rừng là bảo vệ cuộc sống của chúng ta!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                              ),
                            ),
                          ),

                          Container(
                            width: 300,
                            margin: const EdgeInsets.only(bottom: 32),
                            child: Text(
                              'Ứng dụng quản lý thông tin diện tích của đất nông hộ, nhằm thay thế cho các phương tiện khác.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Encode Sans',
                                fontSize: 18,
                                color: white.withAlpha(190),
                                height: 1.25,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonPrimaryColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: 300,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Đăng nhập',
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
                  ), // ⚪ Nút Đăng nhập
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
