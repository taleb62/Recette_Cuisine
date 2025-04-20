import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../ui/screens/detail_page.dart';

class HomeController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var recipes = <Map<String, dynamic>>[].obs;
  var filteredRecipes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
    debounce(searchQuery, (_) => filterRecipes(), time: Duration(milliseconds: 300));
  }

  Future<void> fetchRecipes() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('recipe').select('*, ingredient(*), review(rate)');

      if (response != null && response is List) {
        recipes.value = List<Map<String, dynamic>>.from(response.map((recipe) {
          final reviews = List<Map<String, dynamic>>.from(recipe['review'] ?? []);
          final averageRate = reviews.isNotEmpty
              ? reviews.map((r) => r['rate'] as int).reduce((a, b) => a + b) / reviews.length
              : 0.0;
          final reviewCount = reviews.length;

          return {
            ...recipe,
            'averageRate': averageRate,
            'reviewCount': reviewCount,
          };
        }));

        filteredRecipes.value = recipes;
      } else {
        Get.snackbar('Error', 'Failed to fetch recipes.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterRecipes() {
    final query = searchQuery.value.toLowerCase();

    filteredRecipes.value = recipes.where((recipe) {
      final name = recipe['name'].toString().toLowerCase();
      final ingredients = List.from(recipe['ingredient'])
          .map((ing) => ing['name'].toString().toLowerCase())
          .toList();

      return name.contains(query) || ingredients.any((ing) => ing.contains(query));
    }).toList();
  }

  void goToDetails(Map<String, dynamic> recipe) {
    Navigator.of(Get.context!).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailPage(recipe: recipe),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void addRecipeToList(Map<String, dynamic> recipe) {
    recipes.insert(0, recipe); // Add the recipe to the top of the list
    filteredRecipes.value = recipes; // Update filtered list
  }
}
