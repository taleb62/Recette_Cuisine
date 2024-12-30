class recipe {
  final int recipeId;
  final int price;
  final String size;
  final double rating;
  final int humidity;
  final String temperature;
  final String category;
  final String recipeName;
  final String imageURL;
  bool isFavorated;
  final String decription;
  bool isSelected;

  recipe(
      {required this.recipeId,
      required this.price,
      required this.category,
      required this.recipeName,
      required this.size,
      required this.rating,
      required this.humidity,
      required this.temperature,
      required this.imageURL,
      required this.isFavorated,
      required this.decription,
      required this.isSelected});

  //List of recipes data
  static List<recipe> recipeList = [
    recipe(
        recipeId: 0,
        price: 22,
        category: 'Indoor',
        recipeName: 'Sanseviera',
        size: 'Small',
        rating: 4.5,
        humidity: 34,
        temperature: '23 - 34',
        imageURL: 'assets/images/meal.png',
        isFavorated: true,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 1,
        price: 11,
        category: 'Outdoor',
        recipeName: 'Philodendron',
        size: 'Medium',
        rating: 4.8,
        humidity: 56,
        temperature: '19 - 22',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 2,
        price: 18,
        category: 'Indoor',
        recipeName: 'Beach Daisy',
        size: 'Large',
        rating: 4.7,
        humidity: 34,
        temperature: '22 - 25',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 3,
        price: 30,
        category: 'Outdoor',
        recipeName: 'Big Bluestem',
        size: 'Small',
        rating: 4.5,
        humidity: 35,
        temperature: '23 - 28',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 4,
        price: 24,
        category: 'Recommended',
        recipeName: 'Big Bluestem',
        size: 'Large',
        rating: 4.1,
        humidity: 66,
        temperature: '12 - 16',
        imageURL: 'assets/images/meal.png',
        isFavorated: true,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 5,
        price: 24,
        category: 'Outdoor',
        recipeName: 'Meadow Sage',
        size: 'Medium',
        rating: 4.4,
        humidity: 36,
        temperature: '15 - 18',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 6,
        price: 19,
        category: 'Garden',
        recipeName: 'Plumbago',
        size: 'Small',
        rating: 4.2,
        humidity: 46,
        temperature: '23 - 26',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 7,
        price: 23,
        category: 'Garden',
        recipeName: 'Tritonia',
        size: 'Medium',
        rating: 4.5,
        humidity: 34,
        temperature: '21 - 24',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    recipe(
        recipeId: 8,
        price: 46,
        category: 'Recommended',
        recipeName: 'Tritonia',
        size: 'Medium',
        rating: 4.7,
        humidity: 46,
        temperature: '21 - 25',
        imageURL: 'assets/images/meal.png',
        isFavorated: false,
        decription:
            'This recipe is one of the best recipe. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
  ];

  //Get the favorated items
  static List<recipe> getFavoritedrecipes() {
    List<recipe> _travelList = recipe.recipeList;
    return _travelList.where((element) => element.isFavorated == true).toList();
  }

  //Get the cart items
  static List<recipe> addedToCartrecipes() {
    List<recipe> _selectedrecipes = recipe.recipeList;
    return _selectedrecipes
        .where((element) => element.isSelected == true)
        .toList();
  }
}
