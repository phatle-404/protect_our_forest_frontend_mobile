import 'package:flutter/material.dart';
import 'package:protect_our_forest/screens/home_not_login/login/login.dart';
import 'package:protect_our_forest/services/auth_service.dart';
import '../../../config/background.dart';
import '../../../config/colors.dart';

class MoreInfoScreen extends StatefulWidget {
  final String email;
  final String password;

  const MoreInfoScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  MoreInfoScreenState createState() => MoreInfoScreenState();
}

class MoreInfoScreenState extends State<MoreInfoScreen> {
  final TextEditingController nameController = TextEditingController();

  String? selectedDistrict;
  String? selectedProvince;

  final List<String> districts = [
    'Phường 1',
    'Phường 2',
    'Xã Tân Lập',
    'Xã Hòa Bình',
  ];

  final List<String> provinces = [
    'TP. Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'An Giang',
  ];

  bool isLoading = false;

  final authService = AuthService();

  Future<void> _submitRegistration() async {
    if (isLoading) return;

    final userName = nameController.text.trim();

    if (userName.isEmpty) {
      _showError('Vui lòng nhập tên của bạn.');
      return;
    }

    if (selectedDistrict == null || selectedProvince == null) {
      _showError('Vui lòng chọn quận/huyện và tỉnh/thành phố.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Call your registration service here
      await authService.register(
        userName,
        widget.email,
        widget.password,
        selectedDistrict!,
        selectedProvince!,
      );
      if (!mounted) return;
      // Navigate to login screen after successful registration
      _showSuccess('Đăng ký thành công.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
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

                // Logo
                Image.asset(
                  'assets/image/home/logo_square.png', // icon app
                  height: 259,
                ),

                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
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
                      padding: const EdgeInsets.only(left: 40, top: 5),
                      child: const Text(
                        'Vui lòng điền thêm thông tin.',
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
                    padding: const EdgeInsets.fromLTRB(40, 30, 40, 10),
                    decoration: BoxDecoration(
                      color: white.withAlpha(40),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tên chủ hộ',
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
                                controller: nameController,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nhập tên',
                                  prefixIcon: Icon(Icons.person),
                                  suffixIcon: null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tỉnh/thành phố',
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
                            _buildDropdownField(
                              hint: 'Chọn tỉnh/thành phố',
                              icon: Icons.location_city,
                              items: provinces,
                              value: selectedProvince,
                              onChanged: (value) =>
                                  setState(() => selectedProvince = value),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quận/huyện',
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
                            _buildDropdownField(
                              hint: 'Chọn quận/huyện',
                              icon: Icons.home,
                              items: districts,
                              value: selectedDistrict,
                              onChanged: (value) =>
                                  setState(() => selectedDistrict = value),
                              enabled: selectedProvince != null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _submitRegistration,
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
                              'Đăng ký',
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

  Widget _buildDropdownField({
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required void Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        value: enabled ? value : null,
        hint: Text(hint),
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: enabled ? Colors.black : Colors.grey),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: enabled ? onChanged : null,
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
