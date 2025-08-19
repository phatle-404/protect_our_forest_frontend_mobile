import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:protect_our_forest/models/farmland.dart';
import 'package:protect_our_forest/models/user.dart';
import 'package:protect_our_forest/screens/home/farmland/create_farmland/camera.dart';
import 'package:protect_our_forest/screens/home/farmland/farmland_detail.dart'
    as farmland_detail;
import 'package:protect_our_forest/services/farmland_service.dart';
import 'package:intl/intl.dart';

class LocationScreen extends StatefulWidget {
  final User? user;
  const LocationScreen({super.key, this.user});

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  bool isApprovedExpanded = true;
  bool isPendingExpanded = false;
  bool isWarningExpanded = false;

  List<Farmland> farmlands = [];

  @override
  void initState() {
    super.initState();
    _loadFarmlandData(widget.user?.userId ?? '');
  }

  Future<void> _loadFarmlandData(String userId) async {
    try {
      final areas = await FarmlandDataService.getFarmlandByUser(userId);
      if (mounted) {
        setState(() {
          farmlands = areas;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu vùng canh tác: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lọc dữ liệu
    final approved = farmlands
        .where((f) => f.state == FarmlandState.approved)
        .toList();
    final pending = farmlands
        .where((f) => f.state == FarmlandState.pending)
        .toList();
    final warning = approved.where((f) => f.intersectionArea > 0).toList();

    // Tổng diện tích vùng active (kể cả cảnh báo)
    final totalArea =
        approved.fold<double>(0.0, (sum, f) => sum + f.area) +
        warning.fold<double>(0.0, (sum, f) => sum + f.area);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vùng canh tác',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: homeBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          },
          icon: const Icon(LucideIcons.plus, color: Colors.black, size: 27),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 27,
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 10),
      ),
      backgroundColor: homeBackgroundColor,
      body: ForestBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
              child: Column(
                children: [
                  _statRow(
                    icon: Image.asset(
                      'assets/image/location/location_icon.png',
                      height: 40,
                    ),
                    title: 'Vùng đã phê duyệt',
                    value: approved.length.toString(),
                  ),
                  const SizedBox(height: 10),
                  _statRow(
                    icon: Image.asset(
                      'assets/image/location/lucide_land-plot.png',
                      height: 40,
                    ),
                    title: 'Tổng diện tích',
                    value: '${totalArea.toStringAsFixed(2)} ha',
                  ),
                  const SizedBox(height: 10),
                  _statRow(
                    icon: const Icon(
                      LucideIcons.loader,
                      color: Color(0xff307D24),
                      size: 40,
                    ),
                    title: 'Vùng chờ phê duyệt',
                    value: pending.length.toString(),
                  ),
                  const SizedBox(height: 10),
                  _statRow(
                    icon: const Icon(
                      LucideIcons.triangleAlert,
                      color: Color(0xffFF0000),
                      size: 40,
                    ),
                    title: 'Cảnh báo xâm lấn',
                    value: warning.length.toString(),
                  ),
                  const SizedBox(height: 30),

                  // Vùng đã phê duyệt
                  _expandableSection(
                    color: Colors.green,
                    title: 'Đã phê duyệt',
                    expanded: isApprovedExpanded,
                    onTap: () => setState(
                      () => isApprovedExpanded = !isApprovedExpanded,
                    ),
                    children: approved
                        .where((f) => f.intersectionArea == 0)
                        .map(
                          (f) => _regionCard(
                            title: f.farmlandName,
                            date: DateFormat(
                              'HH:mm dd/MM/yyyy',
                            ).format(f.startDate?.toLocal() ?? DateTime.now()),
                            farmland: f,
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(color: Colors.black, thickness: 0.5),

                  // Chờ phê duyệt
                  _expandableSection(
                    color: Colors.orange,
                    title: 'Chờ phê duyệt',
                    expanded: isPendingExpanded,
                    onTap: () =>
                        setState(() => isPendingExpanded = !isPendingExpanded),
                    children: pending
                        .map(
                          (f) => _regionCard(
                            title: f.farmlandName,
                            date: '', // Chưa duyệt → không hiển thị ngày
                            farmland: f,
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(color: Colors.black, thickness: 0.5),

                  // Cảnh báo xâm lấn
                  _expandableSection(
                    color: Colors.red,
                    title: 'Cảnh báo xâm lấn',
                    expanded: isWarningExpanded,
                    onTap: () =>
                        setState(() => isWarningExpanded = !isWarningExpanded),
                    children: warning
                        .map(
                          (f) => _regionCard(
                            title: f.farmlandName,
                            date: DateFormat(
                              'HH:mm dd/MM/yyyy',
                            ).format(f.startDate?.toLocal() ?? DateTime.now()),
                            farmland: f,
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(color: Colors.black, thickness: 0.5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow({
    required Widget icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _expandableSection({
    required Color color,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    List<Widget> children = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Icon(Icons.circle, color: color, size: 12),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ConstrainedBox(
            constraints: expanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 0),
            child: Column(children: children),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _regionCard({required String title, required String date, required Farmland farmland}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  farmland_detail.FarmlandDetailScreen(farmland: farmland),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/image/location/land_field.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (date.isNotEmpty)
                    Text(
                      date,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                ],
              ),
              const Icon(LucideIcons.mapPin, color: Colors.white, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
