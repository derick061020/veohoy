import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración para pantalla completa
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge
  );

  
  // Configurar colores de la barra de sistema
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: true,
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
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white) // Fondo blanco para el WebView
      ..loadRequest(Uri.parse('https://veohoy.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para el Scaffold
      body: Container(
        color: Colors.white, // Fondo blanco para el contenedor
        child: SafeArea(
          top: true,
          bottom: true, // Desactivamos el SafeArea inferior para manejar el color manualmente
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      ),
    );
  }
}