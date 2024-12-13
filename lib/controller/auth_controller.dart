import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // TextEditingControllers pour collecter les informations utilisateur
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();

  // Champs de validation (pour mise à jour dynamique UI)
  var isEmailValid = true.obs;
  var isPasswordValid = true.obs;
  var isConfirmPasswordValid = true.obs;
  var isNameValid = true.obs;
  var isPhoneValid = true.obs;

  // Image choisie par l'utilisateur
  File? selectedImage;

  // Fonction pour sélectionner une image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      update(); // Met à jour l'interface utilisateur si nécessaire
    } else {
      Get.snackbar("Info", "Aucune image sélectionnée.");
    }
  }

  // Fonction pour uploader une image dans Supabase Storage
  Future<String?> uploadImage(String userId) async {
    if (selectedImage == null) return null;

    try {
      final fileName = "${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final filePath = selectedImage!.path;

      final response = await supabase.storage
          .from('photos_bucket')
          .upload(fileName, File(filePath));

      // if (response.error != null) {
      //   throw Exception("Erreur lors de l'upload de l'image : ${response.error!.message}");
      // }

      // Récupérer l'URL ou le chemin de l'image
      final publicUrl = supabase.storage.from('photos_bucket').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
      return null;
    }
  }

  // Fonction de login
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Validation des champs
    if (email.isEmpty || !email.isEmail) {
      isEmailValid.value = false;
      return;
    }
    if (password.isEmpty || password.length < 6) {
      isPasswordValid.value = false;
      return;
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        Get.snackbar(
          "Succès",
          "Connexion réussie",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        emailController.clear();
        passwordController.clear();
        Get.offAllNamed('/homescreen'); // Redirige vers la page d'accueil
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fonction de signup
  Future<void> signup() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    // Validation des champs
    if (name.isEmpty) {
      isNameValid.value = false;
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      isPhoneValid.value = false;
      return;
    }
    if (email.isEmpty || !email.isEmail) {
      isEmailValid.value = false;
      return;
    }
    if (password.isEmpty || password.length < 6) {
      isPasswordValid.value = false;
      return;
    }
    if (password != confirmPassword) {
      isConfirmPasswordValid.value = false;
      return;
    }

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Uploader l'image si une image a été sélectionnée
        String? imagePath = await uploadImage(response.user!.id);

        // Ajouter l'utilisateur dans la table `user`
        final insertResponse = await supabase.from('user').insert({
          'id': response.user!.id, // ID généré par Supabase Auth
          'name': name,
          'phone_number': phone,
          'profile_image': imagePath,
        });

        if (insertResponse.hasError) {
          Get.snackbar(
            "Erreur",
            "Impossible d'ajouter les informations utilisateur : ${insertResponse.error!.message}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        Get.snackbar(
          "Succès",
          "Inscription réussie",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        nameController.clear();
        phoneController.clear();
        selectedImage = null;
        Get.offAllNamed('/login'); // Redirige vers la page de connexion
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    // Nettoyer les contrôleurs à la fermeture du contrôleur
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
