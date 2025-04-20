import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/FavoriteController.dart';

class FavoritePage extends StatelessWidget {
  final FavoriteController controller = Get.put(FavoriteController());

  FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 600;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Favorite Recipes'),
      //   backgroundColor: Colors.purple,
      //   elevation: 0,
      // ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favoritedRecipes.isEmpty) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                const SizedBox(height: 10),
                const Text(
                  'No favorite recipes found!',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideScreen ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemCount: controller.favoritedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = controller.favoritedRecipes[index]['recipe'];

              // Validate recipe data to avoid null errors
              if (recipe == null || recipe['id'] == null) {
                return const SizedBox();
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Recipe Image
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            recipe['image'] ?? '',
                            height: size.width > 600 ? 200 : 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 60),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Serves: ${recipe['people'] ?? 0} | Time: ${recipe['time'] ?? 0} mins',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Favorite Icon for Removing
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => controller.removeFavorite(recipe['id']),
                        child: const Icon(Icons.favorite, color: Colors.red, size: 28),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
