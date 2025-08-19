import 'package:flutter/material.dart';

class NotificationData {
  final String title;
  final String content;
  final String time; // ví dụ: '15:00'
  final String date; // ví dụ: '18/06/2025'
  final bool seen;

  NotificationData({
    required this.title,
    required this.content,
    required this.time,
    required this.date,
    required this.seen,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationData> notifications = [
    NotificationData(
      title: 'Gửi yêu cầu đến cơ quan',
      content:
          'Yêu cầu tạo vùng canh tác đã được gửi đến cơ quan quản lý vùng. Dự tính khoảng 1 ngày nữa sẽ có kết quả cho bạn.',
      time: '15:00',
      date: '18/06/2025',
      seen: false,
    ),
    NotificationData(
      title: 'Kết quả yêu cầu',
      content:
          'Yêu cầu tạo vùng canh tác của bạn đã được phê duyệt. Bạn có thể bắt đầu đánh dấu khu vực trên bản đồ.',
      time: '08:30',
      date: '19/06/2025',
      seen: false,
    ),
    NotificationData(
      title: 'Cảnh báo độ ẩm thấp',
      content:
          'Độ ẩm trong khu vực rừng A đang xuống thấp dưới mức cho phép. Cần kiểm tra ngay để tránh nguy cơ cháy rừng.',
      time: '14:15',
      date: '17/06/2025',
      seen: true,
    ),
    NotificationData(
      title: 'Phản hồi từ cơ quan',
      content:
          'Cơ quan quản lý đã phản hồi yêu cầu của bạn. Vui lòng kiểm tra chi tiết trong mục Yêu cầu.',
      time: '10:00',
      date: '16/06/2025',
      seen: true,
    ),
    NotificationData(
      title: 'Thêm khu vực mới',
      content:
          'Bạn vừa thêm thành công một khu vực canh tác mới tại khu vực B. Đừng quên gắn nhãn cho dễ quản lý.',
      time: '11:45',
      date: '15/06/2025',
      seen: false,
    ),
    NotificationData(
      title: 'Cập nhật bản đồ định vị',
      content:
          'Bản đồ định vị vừa được cập nhật với dữ liệu vệ tinh mới. Hãy đồng bộ để có thông tin chính xác.',
      time: '09:00',
      date: '14/06/2025',
      seen: true,
    ),
    NotificationData(
      title: 'Báo cáo tuần tự động',
      content:
          'Báo cáo tuần đã được tổng hợp và gửi vào email của bạn. Vui lòng kiểm tra trong hộp thư đến.',
      time: '18:00',
      date: '13/06/2025',
      seen: true,
    ),
    NotificationData(
      title: 'Phát hiện xâm lấn',
      content:
          'Hệ thống phát hiện có dấu hiệu xâm lấn vào vùng rừng C. Bạn nên kiểm tra lại tọa độ và ảnh vệ tinh.',
      time: '16:30',
      date: '12/06/2025',
      seen: false,
    ),
    NotificationData(
      title: 'Cập nhật ứng dụng',
      content:
          'Phiên bản mới của ứng dụng đã sẵn sàng. Hãy cập nhật để sử dụng các tính năng theo dõi thời gian thực.',
      time: '12:00',
      date: '11/06/2025',
      seen: true,
    ),
    NotificationData(
      title: 'Yêu cầu chưa hoàn tất',
      content:
          'Bạn còn một yêu cầu chưa hoàn tất gửi đến cơ quan. Vui lòng bổ sung thông tin trước ngày 20/06/2025.',
      time: '17:20',
      date: '10/06/2025',
      seen: false,
    ),
  ];

  void prioritizeUnseenNotifications(List<NotificationData> list) {
    list.sort((a, b) {
      if (a.seen == b.seen) return 0;
      return a.seen ? 1 : -1; // false (chưa đọc) lên trước
    });
  }

  @override
  void initState() {
    super.initState();
    prioritizeUnseenNotifications(notifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        centerTitle: true,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(notifications[index]);
        },
      ),
    );
  }

  // ✅ Hàm dựng 1 item
  Widget _buildNotificationItem(NotificationData data) {
    final String imageURL = !data.seen
        ? 'assets/notification_image/bell-dot.png'
        : 'assets/notification_image/lucide_bell.png';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.seen
            ? Colors.white
            : const Color(0xFFE1F5FE), // Màu nền chưa đọc
        border: const Border(bottom: BorderSide(color: Colors.black26)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imageURL),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: data.seen ? Colors.black54 : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.content.length > 50
                      ? '${data.content.substring(0, 50)}...'
                      : data.content,
                  style: TextStyle(
                    color: data.seen ? Colors.black54 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.time} ${data.date}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
