import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;


  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();


  var isEmailValid = true.obs;
  var isPasswordValid = true.obs;
  var isConfirmPasswordValid = true.obs;
  var isNameValid = true.obs;
  var isPhoneValid = true.obs;


  File? selectedImage;
  RxString uploadedImageUrl = ''.obs; 


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      update(); 
    } else {
      Get.snackbar("Info", "Aucune image sélectionnée.");
    }
  }

  
  Future<void> uploadImage(String userId) async {
    if (selectedImage == null) {
      Get.snackbar("Erreur", "Veuillez sélectionner une image.");
      return;
    }

    try {
      final fileName = "${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final filePath = selectedImage!.path;

    
      final filePathOnBucket = await supabase.storage
          .from('photos_bucket')
          .upload(fileName, File(filePath));

      if (filePathOnBucket != null) {
        
        final publicUrl =
            supabase.storage.from('photos_bucket').getPublicUrl(fileName);
        uploadedImageUrl.value = publicUrl;
        Get.snackbar("Succès", "Image téléchargée avec succès.");
      } else {
        throw Exception("Erreur lors de l'upload. Aucune réponse valide.");
      }
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    }
  }


  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    
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
        Get.offAllNamed('/homescreen'); 
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


  Future<void> signup() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

  
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
        
        await uploadImage(response.user!.id);

      
        final insertResponse = await supabase.from('user').insert({
          'id': response.user!.id, 
          'name': name,
          'phone_number': phone,
          'profile_image': uploadedImageUrl.value,
        });

        if (insertResponse.error == null) {
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
          Get.offAllNamed('/login'); 
        } else {
          throw Exception(
              "Impossible d'ajouter les informations utilisateur : ${insertResponse.error!.message}");
        }
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
    
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
