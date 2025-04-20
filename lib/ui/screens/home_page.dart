import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/HomeController.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Recipes'),
      //   backgroundColor: Color(0xFF493AD5),
      //   elevation: 0,
      // ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Color(0xFF493AD5)),
                hintText: 'Search recipes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // Recipe Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.filteredRecipes.isEmpty) {
                return Center(child: Text('No recipes found.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: controller.filteredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = controller.filteredRecipes[index];
                  final averageRate = recipe['averageRate'] ?? 0.0;
                  final reviewCount = recipe['reviewCount'] ?? 0;

                  return GestureDetector(
                    onTap: () => controller.goToDetails(recipe),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Recipe Image
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              recipe['image'] ?? '',
                              height: size.width > 600 ? 200 : 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: size.width > 600 ? 200 : 120,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image, size: 48, color: Colors.grey),
                                );
                              },
                            ),
                          ),

                          // Recipe Info
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Name
                                Text(
                                  recipe['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),

                                // Servings and Time
                                Text(
                                  'Serves: ${recipe['people']} | Time: ${recipe['time']} mins',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),

                                // Rating and Reviews
                                Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < averageRate ? Icons.star : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      );
                                    }),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '($reviewCount reviews)',
                                        style: TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
