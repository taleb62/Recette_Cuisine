import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';


class MyRecipesController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var myRecipes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyRecipes();
  }

  Future<void> fetchMyRecipes() async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final response = await supabase
          .from('recipe')
          .select('*, ingredient(*), review(rate)')
          .eq('user_id', user.id);

      if (response != null && response is List) {
        myRecipes.value = List<Map<String, dynamic>>.from(response);
      } else {
        Get.snackbar('Error', 'Failed to fetch recipes');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRecipes() async {
    await fetchMyRecipes(); // Re-fetch recipes to reflect updates
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await supabase.from('recipe').delete().eq('id', recipeId);
      await fetchMyRecipes();
      Get.snackbar('Success', 'Recipe deleted successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete recipe: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void confirmDelete(String recipeId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteRecipe(recipeId);
              Get.back(); // Close dialog after deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
