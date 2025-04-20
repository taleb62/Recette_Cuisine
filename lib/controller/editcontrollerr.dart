import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/MyRecipeController.dart';

class EditRecipeController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Recipe fields
  final nameController = TextEditingController();
  final timeController = TextEditingController();
  final peopleController = TextEditingController();
  final rateController = TextEditingController();

  // Image management
  Rx<File?> selectedImage = Rx<File?>(null);

  // Ingredients list
  RxList<Map<String, dynamic>> ingredients = RxList<Map<String, dynamic>>();

  late String recipeId; // To track the current recipe

  final MyRecipesController myRecipesController = Get.find<MyRecipesController>();

  void setInitialData(Map<String, dynamic> recipe) {
    recipeId = recipe['id'];
    nameController.text = recipe['name'];
    timeController.text = recipe['time'].toString();
    peopleController.text = recipe['people'].toString();
    rateController.text = recipe['rate'].toString();
    ingredients.value = List<Map<String, dynamic>>.from(recipe['ingredient'] ?? []);
  }

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

  Future<void> updateRecipe() async {
    try {
      String? imageUrl;

      if (selectedImage.value != null) {
        final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage
            .from('photos_bucket')
            .upload(fileName, selectedImage.value!);
        imageUrl = supabase.storage.from('photos_bucket').getPublicUrl(fileName);
      }

      // Update recipe details
      await supabase.from('recipe').update({
        'name': nameController.text.trim(),
        'time': int.parse(timeController.text.trim()),
        'people': int.parse(peopleController.text.trim()),
        'rate': int.parse(rateController.text.trim()),
        if (imageUrl != null) 'image': imageUrl,
      }).eq('id', recipeId);

      // Update ingredients
      await supabase.from('ingredient').delete().eq('recipe_id', recipeId);

      for (var ingredient in ingredients) {
        await supabase.from('ingredient').insert({
          'name': ingredient['name'],
          'amount': double.parse(ingredient['amount'].toString()), // Ensure double type
          'unit': ingredient['unit'],
          'recipe_id': recipeId,
        });
      }

      Get.snackbar('Success', 'Recipe updated successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);

      await myRecipesController.refreshRecipes(); // Refresh recipes
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update recipe: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void addIngredient(String name, double amount, String unit) {
    ingredients.add({'name': name, 'amount': amount, 'unit': unit});
  }

  void updateIngredient(int index, String name, double amount, String unit) {
    ingredients[index] = {'name': name, 'amount': amount, 'unit': unit};
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
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
