import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  void navigateToDetails(Map<String, dynamic> recipe) {
    Get.toNamed('/details', arguments: recipe);
  }

  Future<void> addToFavorites(String recipeId) async {
    try {
      await supabase.from('favorite').insert({
        'user_id': supabase.auth.currentUser!.id,
        'recipe_id': recipeId,
      });
      Get.snackbar('Success', 'Recipe added to favorites');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
