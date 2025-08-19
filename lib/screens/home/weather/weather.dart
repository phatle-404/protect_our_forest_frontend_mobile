import 'package:flutter/material.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/screens/home/notification/notification.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thời tiết',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: homeBackgroundColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 27,
            ),
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 10),
      ),
      backgroundColor: homeBackgroundColor,
      body: ForestBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: weatherTheme,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'Đà Lạt',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Icon(LucideIcons.sunMedium600, color: sunColor, size: 200),

                    SizedBox(height: 20),

                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 72,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(text: '28'),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.top,
                            child: Transform.translate(
                              offset: const Offset(
                                0,
                                -5,
                              ), // dịch lên để giống mũ
                              child: Text(
                                '°C',
                                style: TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Nắng nhẹ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Thứ hai, 25/6',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),

                    SizedBox(height: 5),

                    Divider(
                      color: Colors.white70,
                      thickness: 0.5,
                      indent: 20,
                      endIndent: 20,
                    ),

                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              LucideIcons.wind,
                              color: Colors.white,
                              size: 30,
                            ),
                            Text(
                              '10 km/h',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Gió',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              LucideIcons.droplet,
                              color: Colors.white,
                              size: 30,
                            ),
                            Text(
                              '60%',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Độ ẩm',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              LucideIcons.cloudRainWind,
                              color: Colors.white,
                              size: 30,
                            ),
                            Text(
                              '60%',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Mưa',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                children: [
                  forecastItem(
                    "28°C",
                    "26/6",
                    Icon(Icons.sunny, color: sunColor, size: 40),
                  ),
                  forecastItem(
                    "28°C",
                    "26/6",
                    Icon(Icons.sunny, color: sunColor, size: 40),
                  ),
                  forecastItem(
                    "21°C",
                    "Nay",
                    Icon(Icons.cloud, color: white, size: 40),
                    highlight: true,
                  ),
                  forecastItem(
                    "21°C",
                    "24/6",
                    Icon(Icons.cloud, color: Colors.grey.shade500, size: 40),
                  ),
                  forecastItem(
                    "28°C",
                    "26/6",
                    Icon(Icons.sunny, color: sunColor, size: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forecastItem(
    String temp,
    String day,
    Icon icon, {
    bool highlight = false,
  }) {
    return Container(
      width: 70,
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight ? weatherTheme : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: highlight
            ? null
            : Border.all(color: Colors.black12, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            temp,
            style: TextStyle(
              color: highlight ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon,
          Text(
            day,
            style: TextStyle(
              color: highlight ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
