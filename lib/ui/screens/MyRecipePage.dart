import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/MyRecipeController.dart';
import '../../ui/screens/edit_recipe.dart';
import '../../ui/screens/detailmyecipe.dart';


class MyRecipesPage extends StatelessWidget {
  final MyRecipesController controller = Get.put(MyRecipesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: const Color(0xFF493AD5),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myRecipes.isEmpty) {
          return const Center(child: Text('No recipes found.'));
        }

        return ListView.builder(
          itemCount: controller.myRecipes.length,
          itemBuilder: (context, index) {
            final recipe = controller.myRecipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: recipe['image'] != null && recipe['image'].isNotEmpty
                    ? Image.network(
                        recipe['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
                title: Text(recipe['name']),
                subtitle: Text('Time: ${recipe['time']} mins | Serves: ${recipe['people']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Get.to(() => EditRecipePage(recipe: recipe)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.confirmDelete(recipe['id']),
                    ),
                  ],
                ),
                onTap: () {
                  // Redirection vers la page des détails
                  Get.to(() => DetailPage(recipe: recipe));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
