// import 'package:flutter/material.dart';
// import 'package:pifront/constants.dart';
// import 'package:pifront/models/recipes.dart';
// import 'package:pifront/ui/screens/widgets/recipe_widget.dart';

// class CartPage extends StatefulWidget {
//   final List<recipe> addedToCartrecipes;
//   const CartPage({Key? key, required this.addedToCartrecipes})
//       : super(key: key);

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: widget.addedToCartrecipes.isEmpty
//           ? Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 100,
//                     child: Image.asset('assets/images/add-cart.png'),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     'Your Cart is Empty',
//                     style: TextStyle(
//                       color: Constants.primaryColor,
//                       fontWeight: FontWeight.w300,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
//               height: size.height,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                         itemCount: widget.addedToCartrecipes.length,
//                         scrollDirection: Axis.vertical,
//                         physics: const BouncingScrollPhysics(),
//                         itemBuilder: (BuildContext context, int index) {
//                           return recipeWidget(
//                               index: index,
//                               recipeList: widget.addedToCartrecipes);
//                         }),
//                   ),
//                   Column(
//                     children: [
//                       const Divider(
//                         thickness: 1.0,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Totals',
//                             style: TextStyle(
//                               fontSize: 23,
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                           Text(
//                             r'$65',
//                             style: TextStyle(
//                               fontSize: 24.0,
//                               color: Constants.primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
