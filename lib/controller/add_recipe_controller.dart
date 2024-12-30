import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/HomeController.dart';

class AddRecipeController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final HomeController homeController = Get.find<HomeController>(); // Access HomeController

  // Text controllers
  final nameController = TextEditingController();
  final timeController = TextEditingController();
  final peopleController = TextEditingController();
  final rateController = TextEditingController();

  // Ingredients management
  RxList<Map<String, String>> ingredients = RxList<Map<String, String>>();

  // Image management
  Rx<File?> selectedImage = Rx<File?>(null);

  // Pick an image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      Get.snackbar('Success', 'Image selected successfully.');
    } else {
      Get.snackbar('Info', 'No image selected.');
    }
  }

  // Upload image to Supabase storage
  Future<String?> uploadImage() async {
    if (selectedImage.value == null) return null;

    try {
      final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = selectedImage.value!.path;

      await supabase.storage.from('photos_bucket').upload(fileName, File(filePath));
      final publicUrl = supabase.storage.from('photos_bucket').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  // Add an ingredient
  void addIngredient(String name, String amount, String unit) {
    ingredients.add({'name': name, 'amount': amount, 'unit': unit});
  }

  // Remove an ingredient
  void removeIngredient(int index) {
    ingredients.removeAt(index);
  }

  // Save recipe and notify HomeController
  Future<void> saveRecipe() async {
    try {
      final String name = nameController.text.trim();
      final int time = int.parse(timeController.text.trim());
      final int people = int.parse(peopleController.text.trim());
      final int rate = int.parse(rateController.text.trim());

      // Upload image if available
      final String? imageUrl = await uploadImage();

      // Insert recipe into Supabase
      final response = await supabase.from('recipe').insert({
        'name': name,
        'time': time,
        'image': imageUrl,
        'people': people,
        'rate': rate,
      }).select().single();

      final String recipeId = response['id'];

      // Insert ingredients associated with the recipe
      for (var ingredient in ingredients) {
        await supabase.from('ingredient').insert({
          'name': ingredient['name'],
          'amount': double.parse(ingredient['amount']!),
          'unit': ingredient['unit'],
          'recipe_id': recipeId,
        });
      }

      // Update the HomeController recipes list
      final newRecipe = {
        'id': recipeId,
        'name': name,
        'time': time,
        'image': imageUrl,
        'people': people,
        'rate': rate,
        'ingredient': ingredients.map((ing) => {
              'name': ing['name'],
              'amount': ing['amount'],
              'unit': ing['unit'],
            }).toList(),
      };
      homeController.addRecipeToList(newRecipe); // Add the new recipe to HomeController

      Get.snackbar('Success', 'Recipe added successfully!');
      clearFields();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add recipe: $e');
    }
  }

  // Clear fields
  void clearFields() {
    nameController.clear();
    timeController.clear();
    peopleController.clear();
    rateController.clear();
    ingredients.clear();
    selectedImage.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    timeController.dispose();
    peopleController.dispose();
    rateController.dispose();
    super.onClose();
  }
}
