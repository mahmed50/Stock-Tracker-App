import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;

                var user = await dbHelper.signIn(email, password);
                if (user != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(userId: user.uid)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Login failed. Please check your credentials.")),
                  );
                }
              },
              child: Text("Login"),
            ),
            SizedBox(height: 10),
            Text("Don't have an account?"),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
              child: Text("Sign Up Here"),
            ),
          ],
        ),
      ),
    );
  }
}
