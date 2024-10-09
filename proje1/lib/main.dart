import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides(); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = ''; 

  static const String loginUrl = "http://iot.mesemekatronik.com:8070/api/auth/login";
  
  get username => null;

  Future<void> loginService(String username, String password) async {
    setState(() {
      _message = "Giriş yapılıyor..."; 
    });

    Map<String, dynamic> requestData = {
      "username": username,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          "Content-Type": "application/json", 
        },
        body: jsonEncode(requestData), 
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        setState(() {
          _message = "Giriş başarılı! Token: ${responseData['token']}"; 
        });
      } else {
        setState(() {
          _message = "Hata: ${response.statusCode} - ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Bir hata oluştu: $e"; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text.trim(); 
                String password = _passwordController.text.trim(); 

                if (username.isNotEmpty && password.isNotEmpty) {
                  loginService(username, password);
                } else {
                  setState(() {
                    _message = "username ve şifre boş olamaz!"; 
                  });
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16.0),
            Text(_message), 
          ],
        ),
      ),
    );
  }
}
