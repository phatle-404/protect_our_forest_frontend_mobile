import 'package:flutter/material.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:protect_our_forest/models/user.dart';

class UpdateInfoScreen extends StatefulWidget {
  final User? user;
  const UpdateInfoScreen({super.key, this.user});

  @override
  UpdateInfoScreenState createState() => UpdateInfoScreenState();
}

class UpdateInfoScreenState extends State<UpdateInfoScreen> {
  User? _user;
  bool _isLoading = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String selectedDistrict = '';
  String selectedProvince = '';

  final List<String> districts = [
    'Phường 1',
    'Phường 2',
    'Xã Tân Lập',
    'Xã Hòa Bình',
    'Đà Lạt',
    'Vuon Lai',
  ];

  final List<String> provinces = [
    'TP. Ho Chi Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'An Giang',
    'Lâm Đồng',
  ];

  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = false;
        // Khởi tạo giá trị ban đầu từ User
        nameController.text = _user?.userName ?? 'N/A';
        emailController.text = _user?.email ?? 'N/A';
        phoneController.text = _user?.phoneNumber ?? 'N/A';
        selectedDistrict = _user?.district ?? 'Đà Lạt';
        selectedProvince = _user?.province ?? 'Lâm Đồng';
      });
      nameController.addListener(checkChanges);
      emailController.addListener(checkChanges);
      phoneController.addListener(checkChanges);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  void checkChanges() {
    final hasChanged =
        nameController.text != (_user?.userName ?? 'N/A') ||
        emailController.text != (_user?.email ?? 'N/A') ||
        phoneController.text != (_user?.phoneNumber ?? 'N/A') ||
        selectedDistrict != (_user?.district ?? 'Đà Lạt') ||
        selectedProvince != (_user?.province ?? 'Lâm Đồng');

    if (hasChanged != isChanged) {
      setState(() {
        isChanged = hasChanged;
      });
    }
  }

  bool isPasswordVisible = false;
  bool isPasswordConfirmVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(
          'Cập nhật thông tin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: homeBackgroundColor,
      ),
      backgroundColor: homeBackgroundColor,
      body: ForestBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: const AssetImage('assets/image/home/account_image.png'),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
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
                        'Tham gia ngày ${_user?.createdAt ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(174, 0, 0, 0),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      _buildLabel("Tên"),
                      _buildTextField(nameController, Icons.person),
                      _buildLabel("Email"),
                      _buildTextField(emailController, Icons.email),
                      _buildLabel("Số điện thoại"),
                      _buildTextField(phoneController, Icons.phone),
                      _buildLabel("Địa chỉ"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              value: selectedDistrict,
                              items: districts,
                              onChanged: (val) => setState(() {
                                selectedDistrict = val!;
                                checkChanges();
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              value: selectedProvince,
                              items: provinces,
                              onChanged: (val) => setState(() {
                                selectedProvince = val!;
                                checkChanges();
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isChanged
                              ? () {
                                  // TODO: Gửi cập nhật thông tin
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Thông tin đã được cập nhật!')),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9BEBA3),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Cập nhật thông tin',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 350,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}