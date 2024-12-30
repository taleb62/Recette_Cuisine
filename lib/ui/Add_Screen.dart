import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pifront/controller/add_recipe_controller.dart';

class Add_Screen extends StatelessWidget {
  final AddRecipeController controller = Get.put(AddRecipeController());

  Add_Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 2, child: backgroundContainer(context)),
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      imagePickerSection(size),
                      const SizedBox(height: 20),
                      nameField(),
                      const SizedBox(height: 15),
                      timeField(),
                      const SizedBox(height: 15),
                      peopleField(),
                      const SizedBox(height: 15),
                      rateField(),
                      const SizedBox(height: 20),
                      ingredientsSection(),
                      const SizedBox(height: 30),
                      submitButton(), // Bouton visible
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePickerSection(Size size) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: size.height * 0.2,
        width: size.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Obx(() {
          final image = controller.selectedImage.value;
          return image == null
              ? const Center(
                  child: Text(
                    'Cliquez pour ajouter une image',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                );
        }),
      ),
    );
  }

  Widget nameField() =>
      inputField(controller: controller.nameController, label: 'Recipe Name');

  Widget timeField() => inputField(
        controller: controller.timeController,
        label: 'Time (minutes)',
        keyboardType: TextInputType.number,
      );

  Widget peopleField() => inputField(
        controller: controller.peopleController,
        label: 'Number of People',
        keyboardType: TextInputType.number,
      );

  Widget rateField() => inputField(
        controller: controller.rateController,
        label: 'Rating (1-5)',
        keyboardType: TextInputType.number,
      );

  Widget ingredientsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color:  const Color(0xFF593AD5)),
              onPressed: () => showAddIngredientDialog(),
            ),
          ],
        ),
        SizedBox(
          height: 150,
          child: Obx(() => ListView.builder(
                itemCount: controller.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = controller.ingredients[index];
                  return ListTile(
                    title: Text(ingredient['name']!),
                    subtitle:
                        Text('${ingredient['amount']} ${ingredient['unit']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        controller.removeIngredient(index);
                      },
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }

  void showAddIngredientDialog() {
    final ingredientNameController = TextEditingController();
    final ingredientAmountController = TextEditingController();
    final ingredientUnitController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Add Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            inputField(
                controller: ingredientNameController, label: 'Ingredient Name'),
            const SizedBox(height: 10),
            inputField(
              controller: ingredientAmountController,
              label: 'Amount',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            inputField(controller: ingredientUnitController, label: 'Unit'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addIngredient(
                ingredientNameController.text,
                ingredientAmountController.text,
                ingredientUnitController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget submitButton() {
    return GestureDetector(
      onTap: () async {
        if (controller.nameController.text.isEmpty ||
            controller.timeController.text.isEmpty ||
            controller.peopleController.text.isEmpty ||
            controller.rateController.text.isEmpty ||
            controller.selectedImage.value == null) {
          Get.snackbar(
            'Erreur',
            'Veuillez remplir tous les champs et sélectionner une image.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        await controller.saveRecipe();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color:  const Color(0xFF593AD5),
        ),
        width: 120,
        height: 50,
        child: const Text(
          'Submit',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: label,
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: Color.fromARGB(255, 34, 207, 80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: const Color(0xFF593AD5)),
          ),
        ),
      ),
    );
  }

  Widget backgroundContainer(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height * 0.25,
      decoration: const BoxDecoration(
        color:  const Color(0xFF593AD5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Add Recipe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Icon(Icons.attach_file_outlined, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
