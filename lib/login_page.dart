/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Nelson Chung
 * Creation Date: September 6, 2023
 */
 
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Show a success message using SnackBar
      final snackBar = SnackBar(content: Text('登入成功！'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Save user data to shared preferences using JSON serialization
      final userData = {
        'id': userCredential.user?.uid,
        'displayName': userCredential.user?.displayName,
        'email': userCredential.user?.email,
        'photoUrl': userCredential.user?.photoURL,
      };
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_data', jsonEncode(userData));

      // Navigate to the main page (MainPage)
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
    } catch (error) {
      // Handle any errors that occurred during the Google Sign In process
      print('Error occurred during Google Sign In: $error');

      if (error is FirebaseAuthException) {
        // Handle FirebaseAuthException
        final snackBar = SnackBar(content: Text('登入失敗：${error.message}'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // Handle other types of errors
        final snackBar = SnackBar(content: Text('登入失敗！'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  InputDecoration _inputDecoration(IconData icon, String labelText) {
    return InputDecoration(
      fillColor: Color(0xFFF1F6FB),
      filled: true,
      prefixIcon: Icon(icon, color: Color(0xFF8189B0)),
      labelText: labelText,
      labelStyle: TextStyle(color: Color(0xFF8189B0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(  // <-- 添加此行
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel, size: 30.0),
                      SizedBox(width: 10.0),
                      Text('帳號登入', style: TextStyle(fontSize: 24.0)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80.0),
              Text('Welcome Back!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
              SizedBox(height: 10.0),
              Text('Please enter your account here.', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 40.0),
              TextField(
                decoration: _inputDecoration(Icons.email, 'Email'),
              ),
              SizedBox(height: 20.0),
              TextField(
                obscureText: _isObscured,
                decoration: _inputDecoration(Icons.lock, 'Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Color(0xFF8189B0)),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text('Forgot password?', style: TextStyle(color: Colors.blue[900])),
                    onPressed: () {
                      // TODO: Handle forgot password
                    },
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 啟動 main_page.dart
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
                  },
                  child: Text('Login in'),
                  style: ElevatedButton.styleFrom(primary: Colors.blue[900], onPrimary: Colors.white),
                ),
              ),
//
              SizedBox(height: 3.0), // 加入這行，為按鈕提供間距
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleGoogleSignIn(context),
                  child: Text('Google Login'),
                  style: ElevatedButton.styleFrom(primary: Colors.red, onPrimary: Colors.white),  // 使用Google的紅色
                ),
              ),                
              SizedBox(height: 20.0),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Don't have any account? "),
                    TextButton(
                      child: Text('Sign Up', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // TODO: Handle sign up
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
