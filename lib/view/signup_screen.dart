import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class SignupScreen extends StatelessWidget {
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
                "Sign Up",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF493AD5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Name Input Field
              Obx(() => TextField(
                    controller: authController.nameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF493AD5)),
                      labelText: "Name",
                      labelStyle: const TextStyle(color: Color(0xFF493AD5)),
                      errorText: authController.isNameValid.value
                          ? null
                          : "Veuillez entrer un nom",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.name,
                  )),
              const SizedBox(height: 20),

              // Phone Input Field
              Obx(() => TextField(
                    controller: authController.phoneController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, color: Color(0xFF493AD5)),
                      labelText: "Phone",
                      labelStyle: const TextStyle(color: Color(0xFF493AD5)),
                      errorText: authController.isPhoneValid.value
                          ? null
                          : "Veuillez entrer un numéro valide",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.phone,
                  )),
              const SizedBox(height: 20),

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
                          : "Le mot de passe doit comporter au moins 6 caractères",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  )),
              const SizedBox(height: 20),

              // Confirm Password Input Field
              Obx(() => TextField(
                    controller: authController.confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF493AD5)),
                      labelText: "Confirmer le mot de passe",
                      labelStyle: const TextStyle(color: Color(0xFF493AD5)),
                      errorText: authController.isConfirmPasswordValid.value
                          ? null
                          : "Les mots de passe ne correspondent pas",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  )),
              const SizedBox(height: 20),

              // Image Picker
              GestureDetector(
                onTap: authController.pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF493AD5),
                      width: 1.5,
                    ),
                  ),
                  child: authController.selectedImage == null
                      ? const Center(
                          child: Text(
                            "Cliquez pour ajouter une photo",
                            style: TextStyle(
                              color: Color(0xFF493AD5),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            authController.selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              ElevatedButton(
                onPressed: authController.signup,
                child: const Text(
                  "S'inscrire",
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
              const SizedBox(height: 20),

              // Redirect to Login
              TextButton(
                onPressed: () => Get.back(), // Retour à l'écran de connexion
                child: const Text(
                  "Vous avez déjà un compte ? Connectez-vous",
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
