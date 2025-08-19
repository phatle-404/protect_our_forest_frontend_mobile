# 🌱 Protect Our Forest

## 📖 Giới thiệu
**Protect Our Forest** là dự án xây dựng ứng dụng quản lý thông tin diện tích đất của nông hộ, được hiển thị trên đa nền tảng.  
Ứng dụng hỗ trợ nông hộ và cơ quan chức năng theo dõi, quản lý vùng đất canh tác, đồng thời phát hiện các khu vực giao cắt với đất rừng nhằm bảo vệ tài nguyên rừng và hệ sinh thái.

## 🚀 Công nghệ sử dụng
- **Flutter**: Xây dựng ứng dụng mobile đa nền tảng (Android & iOS).  
- **Node.js + Express.js**: Xây dựng API backend (đang phát triển).  
- **MongoDB**: Lưu trữ dữ liệu không gian và thông tin vùng canh tác.  

## 📌 Tính năng chính
- Nhập và quản lý thông tin vùng đất nông hộ theo dữ liệu GPS.  
- Hiển thị vùng canh tác trên bản đồ.  
- Kiểm tra và hiển thị diện tích giao cắt giữa đất nông hộ và đất rừng.  
- Tính toán diện tích bị chồng lấn và cung cấp dữ liệu cho nông hộ/kiểm lâm.  

## ⚙️ Cài đặt và chạy ứng dụng

```bash
# 1. Clone repository
git clone https://github.com/phatle-404/protect_our_forest_frontend_mobile.git
cd protect_our_forest_frontend_mobile

# 2. Cài đặt dependencies
flutter pub get

# 3. Chạy ứng dụng (trên giả lập hoặc thiết bị thật)
flutter emulators --launch <your-device-id>
flutter run
