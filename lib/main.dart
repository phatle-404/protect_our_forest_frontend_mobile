import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_not_login/home_not_login.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProtectOurForestApp());
}

class ProtectOurForestApp extends StatelessWidget {
  const ProtectOurForestApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeNotLoginScreen(),
      title: 'Protect Our Forest',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}


// import 'package:flutter/material.dart';
// import 'screens/home/map/forest.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   final String jsonString = '''
//   {
//     "protected_areas": [
//       {
//         "geojson": {
//           "geometry": {
//             "coordinates": [
//               [[
//                 [106.957, 20.847],
//                 [106.953, 20.835],
//                 [106.957, 20.832],
//                 [106.953, 20.827],
//                 [106.968, 20.807],
//                 [106.997, 20.819],
//                 [106.957, 20.847]
//               ]],
//               [[
//                 [107.124, 20.731],
//                 [107.116, 20.75],
//                 [107.124, 20.731]
//               ]]
//             ]
//           }
//         }
//       }
//     ]
//   }
//   ''';

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Lớp Rừng',
//       home: ForestMapScreen(jsonData: jsonString),
//     );
//   }
// }
