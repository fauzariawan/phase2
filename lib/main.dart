import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:workplan_beta_test/main_pages/attendance/services/locator.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/biometrik_login.dart';
// import 'package:workplan_beta_test/launcher/launcher_view.dart';
import 'package:workplan_beta_test/main_pages/constans.dart';
import 'package:workplan_beta_test/pages/on_boarding_page.dart';
import 'package:workplan_beta_test/router.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'base/system_param.dart';
import 'helper/rest_service.dart';
import 'main_pages/launcher_view.dart';
import 'model/workplan_visit_notification.dart';
import 'pages/loginscreen.dart';
import 'package:http/http.dart' as http;

// const simplePeriodicTask = "CheckInTask";

// void main() => runApp(new MyApp());
// untuk menjalankan task in background
const task = 'updateLocation';
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    switch (taskName) {
      case 'updateLocation':
        updateLocation(inputData);
        break;
      default:
    }
    return Future.value(true);
  });
}

void updateLocation(Map<String, dynamic>? inputData) async {
  print('menjalan kan fungsi untuk update location');
  try {
    var respon = await http.post(
      Uri.parse(SystemParam.baseUrl + SystemParam.liveTracking),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        // "Content-Type": "application/json",
      },
      body: inputData,
    );
    var result = jsonDecode(respon.body);
    if (result['code'] == 0 && result['status'] == 'Success') {
      print('update lokasi berhasil');
    }
    print(respon.body);
    print(result['code']);
    print(result['status']);
  } catch (e) {
    print(e);
    return null;
  }
  // Timer.periodic(Duration(seconds: 1), (timer) {
  //   print('ini dari workmanager update location');
  // });
}

Future<void> main() async {
  // setupServices(); // untuk init locator (getin)
  WidgetsFlutterBinding.ensureInitialized();
  // untuk menjalankan task in background
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  tz.initializeTimeZones(); // untuk init timezone
  try {
    print('cek data User');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // late User user;
    // print(prefs);
    // bool isLogedIn = false;
    // bool isDataUserExist = prefs.containsKey('dataUser');
    // if (isDataUserExist) {
    //   print('ini lihat user masih login to tidak di local');
    //   print('apakah prefs.containsKey masih ada => $isDataUserExist');
    //   var data = jsonDecode(prefs.getString("dataUser").toString());
    //   print(data['is_login_mobile']);
    //   if (data['is_login_mobile'] == "1") {
    //     print('cocok');
    //     isLogedIn = true;
    //   } else {
    //     print('TIDAK COCOK');
    //     data['is_login_mobile'].runtimeType;
    //   }
    //   print(data);
    //   var dataUser;
    //   if (data != null) {
    //     dataUser = json.decode(data);
    //     user = User.fromJson(dataUser);
    //   }
    //   print(dataUser);
    // }
    late User user;
    print(prefs);
    bool isLogedIn = prefs.containsKey('dataUser');
    print('ini lihat user masih login to tidak di local');
    print('apakah prefs.containsKey masih ada => $isLogedIn');
    print(isLogedIn);
    var data = prefs.getString("dataUser");
    print(data);
    var dataUser;
    if (data != null) {
      dataUser = json.decode(data);
      if (dataUser['is_login_mobile'] != "1") isLogedIn = false;
      user = User.fromJson(dataUser);
    }

    print(dataUser);

    Widget halaman = isLogedIn
        ? LandingPage(
            user: user,
            currentIndex: 0,
          )
        : OnBoardingPage();
    runApp(MyApp(halaman: halaman));
  } catch (e) {
    print('ini error ketika sharedpreference nya');
    print(e);
    runApp(MyApp(halaman: OnBoardingPage()));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.halaman}) : super(key: key);
  final Widget? halaman;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('de', 'DE'),
        Locale('en', 'US'),
        Locale('id', 'ID')
      ],
      // initialRoute: '/',
      debugShowCheckedModeBanner: false,
      title: 'Task',
      theme: new ThemeData(
          indicatorColor: SystemParam.colorCustom,
          fontFamily: 'NeoSans',
          // primaryColor: WorkplanPallete.green,
          primarySwatch: SystemParam.colorCustom),
      home: widget.halaman,
      onGenerateRoute: Routers.generateRoute,
    ));
  }

  Future onSelectNotification(String? payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
