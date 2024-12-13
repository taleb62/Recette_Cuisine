import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF493AD5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Email Input Field
              Obx(() => TextField(
                    controller: authController.emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF493AD5)),
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Color(0xFF493AD5)),
                      errorText: authController.isEmailValid.value
                          ? null
                          : "Veuillez entrer un email valide",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  )),
              const SizedBox(height: 20),

              // Password Input Field
              Obx(() => TextField(
                    controller: authController.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF493AD5)),
                      labelText: "Mot de passe",
                      labelStyle: const TextStyle(color: Color(0xFF493AD5)),
                      errorText: authController.isPasswordValid.value
                          ? null
                          : "Veuillez entrer un mot de passe valide",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  )),
              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: authController.login,
                child: const Text(
                  "Se connecter",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF493AD5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Redirect to Signup
              TextButton(
                onPressed: () => Get.toNamed("/signup"),
                child: const Text(
                  "Vous n'avez pas de compte ? Inscrivez-vous",
                  style: TextStyle(
                    color: Color(0xFF493AD5),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
