import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/editcontrollerr.dart';



class EditRecipePage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  EditRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final EditRecipeController controller = Get.put(EditRecipeController());

  @override
  void initState() {
    super.initState();
    controller.setInitialData(widget.recipe); // Inject data into the controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        backgroundColor: const Color(0xFF493AD5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: controller.pickImage,
                child: Obx(() {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: controller.selectedImage.value != null
                        ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                        : widget.recipe['image'] != null && widget.recipe['image'] is String
                            ? Image.network(
                                widget.recipe['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image, size: 100, color: Colors.grey),
                  );
                }),
              ),
              const SizedBox(height: 16),
              inputField(controller.nameController, 'Recipe Name'),
              const SizedBox(height: 10),
              inputField(controller.timeController, 'Time (minutes)', TextInputType.number),
              const SizedBox(height: 10),
              inputField(controller.peopleController, 'Serves', TextInputType.number),
              const SizedBox(height: 10),
              inputField(controller.rateController, 'Rate (1-5)', TextInputType.number),
              const SizedBox(height: 16),

              // Ingredients Section
              const Text('Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = controller.ingredients[index];
                      return ListTile(
                        title: Text(ingredient['name']),
                        subtitle: Text('${ingredient['amount']} ${ingredient['unit']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => showIngredientDialog(
                                  ingredient: ingredient, index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => controller.removeIngredient(index),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
              ElevatedButton(
                onPressed: () => showIngredientDialog(),
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await controller.updateRecipe();
                  Get.offNamed('/myrecipes'); // Redirection après la sauvegarde
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputField(TextEditingController controller, String label,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showIngredientDialog({Map<String, dynamic>? ingredient, int? index}) {
    final ingredientNameController =
        TextEditingController(text: ingredient?['name'] ?? '');
    final ingredientAmountController =
        TextEditingController(text: ingredient?['amount']?.toString() ?? '');
    final ingredientUnitController =
        TextEditingController(text: ingredient?['unit'] ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(ingredient == null ? 'Add Ingredient' : 'Edit Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            inputField(ingredientNameController, 'Ingredient Name'),
            const SizedBox(height: 10),
            inputField(ingredientAmountController, 'Amount (e.g., 1.5)', TextInputType.number),
            const SizedBox(height: 10),
            inputField(ingredientUnitController, 'Unit'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ingredientNameController.text.trim();
              final amount = double.parse(ingredientAmountController.text.trim());
              final unit = ingredientUnitController.text.trim();

              if (ingredient == null) {
                controller.addIngredient(name, amount, unit);
              } else {
                controller.updateIngredient(index!, name, amount, unit);
              }
              Get.back();
            },
            child: Text(ingredient == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
