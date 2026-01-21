import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // <- generado por flutterfire configure
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';



final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

InAppWebViewController? globalWebViewController;

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 NECESARIO para flutter_inappwebview
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <- usa el archivo generado
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Change Status Bar Color',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,  // Color de fondo general
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,  // Color de la barra de estado
          statusBarIconBrightness: Brightness.dark,  // Iconos oscuros
          systemNavigationBarColor: Colors.white,  // Color de la barra de navegación
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: MyHomeScreen(),
      ),
    );
  }
}

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  InAppWebViewController? _controller;
  late PullToRefreshController _pullToRefreshController;


  @override
void initState() {
  super.initState();

  _pullToRefreshController = PullToRefreshController(
    settings: PullToRefreshSettings(
      color: Colors.blue,
    ),
    onRefresh: () async {
      await _controller?.reload();
    },
  );

  _initPushNotifications();
}


Future<void> _initPushNotifications() async {
  await FirebaseMessaging.instance.requestPermission();

  await FirebaseMessaging.instance.subscribeToTopic('all');
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const settings = InitializationSettings(android: androidSettings);

  await localNotifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (response) {
      final url = response.payload;
      if (url != null && globalWebViewController != null) {
        globalWebViewController?.loadUrl(
  urlRequest: URLRequest(url: WebUri(url)),
);
      }
    },
  );

  FirebaseMessaging.onMessage.listen(_showNotification);

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final url = message.data['url'];
    if (url != null && globalWebViewController != null) {
      globalWebViewController?.loadUrl(
  urlRequest: URLRequest(url: WebUri(url)),
);
    }
  });
}
Future<String?> _downloadImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/thumb.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } catch (_) {
    return null;
  }
}
Future<void> _showNotification(RemoteMessage message) async {
  final title = message.notification?.title ?? '';
  final body = message.notification?.body ?? '';
  final url = message.data['url'];
  final imageUrl = message.data['image'];

  BigPictureStyleInformation? style;

  if (imageUrl != null) {
    final imagePath = await _downloadImage(imageUrl);
    if (imagePath != null) {
      style = BigPictureStyleInformation(
        FilePathAndroidBitmap(imagePath),
        contentTitle: title,
        summaryText: body,
      );
    }
  }

  final androidDetails = AndroidNotificationDetails(
    'videos',
    'Videos',
    channelDescription: 'Notificaciones de videos',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: style,
  );

  final details = NotificationDetails(android: androidDetails);

  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    details,
    payload: url,
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Container(
        color: Colors.white, // 🔹 fondo blanco mientras carga
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://veohoy.com'),
          ),
          pullToRefreshController: _pullToRefreshController,
          onWebViewCreated: (controller) {
            _controller = controller;
            globalWebViewController = controller;
          },

          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return NavigationActionPolicy.ALLOW;
          },

          onLoadStop: (controller, url) {
            _pullToRefreshController.endRefreshing();
            _controller?.evaluateJavascript(source: "document.body.style.backgroundColor = 'white';");
          },

          onLoadError: (controller, url, code, message) {
            _pullToRefreshController.endRefreshing();
          },

          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            allowsInlineMediaPlayback: false,
            mediaPlaybackRequiresUserGesture: false,
            userAgent: Platform.isAndroid
                ? "com.ccdevllc.veohoy.android"
                : "com.ccdevllc.veohoy.ios",
            transparentBackground: false, // 🔹 importante
          ),
          

          onEnterFullscreen: (controller) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          },

          onExitFullscreen: (controller) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          },
        ),
      ),
    ),
  );
}

}