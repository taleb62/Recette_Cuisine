import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxList<Map<String, dynamic>> favoritedRecipes = <Map<String, dynamic>>[].obs; // Observable list
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteRecipes(); // Fetch favorites when initialized
  }

  // Fetch favorite recipes
  Future<void> fetchFavoriteRecipes() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('favorite')
          .select('recipe:recipe_id(name, image, time, people)')
          .eq('user_id', supabase.auth.currentUser!.id);

      if (response != null) {
        favoritedRecipes.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Remove a recipe from favorites
  Future<void> removeFavorite(String recipeId) async {
    try {
      await supabase
          .from('favorite')
          .delete()
          .eq('recipe_id', recipeId)
          .eq('user_id', supabase.auth.currentUser!.id);

      fetchFavoriteRecipes(); // Refresh the favorites list
      Get.snackbar('Success', 'Recipe removed from favorites');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
