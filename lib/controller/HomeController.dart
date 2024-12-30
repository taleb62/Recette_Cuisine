import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response = await supabase.from('recipe').select('*, ingredient(*)');

      if (response != null) {
        recipes.value = List<Map<String, dynamic>>.from(response);
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

  // Add a single recipe to the list
  void addRecipeToList(Map<String, dynamic> recipe) {
    recipes.insert(0, recipe); // Insert at the top
    filteredRecipes.value = recipes; // Update the filtered list
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
    Get.toNamed('/details', arguments: recipe);
  }
}
