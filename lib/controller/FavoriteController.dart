import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
class FavoriteController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;


  var isLoading = true.obs;
  var favoritedRecipes = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteRecipes();
  }

  Future<void> fetchFavoriteRecipes() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('favorite')
          .select('recipe:recipe_id(id, name, image, time, people)')
          .eq('user_id', supabase.auth.currentUser!.id);

      if (response != null && response is List) {
        favoritedRecipes.value = List<Map<String, dynamic>>.from(response);
      } else {
        favoritedRecipes.clear();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFE57373), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(String recipeId) async {
    try {
      await supabase
          .from('favorite')
          .delete()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('recipe_id', recipeId);

      // Refresh the list after removal
      await fetchFavoriteRecipes();

      Get.snackbar('Success', 'Recipe removed from favorites',
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFE57373), colorText: Colors.white);
    }
  }
}
