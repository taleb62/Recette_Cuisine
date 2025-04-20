import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pifront/ui/screens/MyRecipePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pifront/constants.dart';
import 'package:pifront/ui/Add_Screen.dart';
import 'package:pifront/ui/screens/favorite_page.dart';
import 'package:pifront/ui/screens/home_page.dart';
import '../controller/FavoriteController.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final FavoriteController favoriteController = Get.put(FavoriteController());

  int _bottomNavIndex = 0;
  bool isDarkMode = false; 

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }

      
      final response = await supabase
          .from('user')
          .select('name, phone_number, profile_image')
          .eq('id', currentUser.id)
          .single();

      if (response != null) {
        
        final email = currentUser.email;

        
        final profileImageUrl = response['profile_image'] != null
            ? supabase.storage
                .from('photos_bucket')
                .getPublicUrl(response['profile_image'])
            : null;

        response['email'] = email; 
        response['profile_image_url'] =
            profileImageUrl; 
        return response;
      } else {
        throw Exception('User data not found in the database');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
      Get.changeTheme(
        isDarkMode ? ThemeData.dark() : ThemeData.light(),
      );
    });
  }

  void logout() async {
    try {
      await supabase.auth.signOut();
      Get.offAllNamed('/login'); 
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e');
    }
  }

  List<Widget> _widgetOptions() {
    return [
      HomePage(),
      FavoritePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _bottomNavIndex == 0 ? 'Home' : 'Favorite',
              style: TextStyle(
                color: Color(0xFF493AD5),
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.dark_mode_rounded,
                color:  Color(0xFF493AD5),
                size: 30.0,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); 
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Add_Screen())); 
        },
        child: Image.asset(
          'assets/images/plus.png',
          height: 30.0,
        ),
        backgroundColor: const Color(0xFF493AD5),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: const Color(0xFF493AD5),
        activeColor: const Color(0xFF493AD5),
        inactiveColor: Colors.black.withOpacity(.5),
        icons: [Icons.home, Icons.favorite],
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;

            
            if (_bottomNavIndex == 1) {
              favoriteController.fetchFavoriteRecipes();
            }
          });
        },
      ),
      endDrawer: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Drawer(
              child: Center(
                child: Text(
                  'Error fetching user data',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Drawer(
              child: Center(
                child: Text('No user data available'),
              ),
            );
          }

          final userData = snapshot.data!;
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Constants.primaryColor),
                  accountName: Text(
                    userData['name'] ?? 'N/A',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    userData['email'] ?? 'N/A',
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: userData['profile_image_url'] != null
                        ? NetworkImage(userData['profile_image_url'])
                        : AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Constants.primaryColor),
                  title: Text('Phone: ${userData['phone_number'] ?? "N/A"}'),
                ),
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Constants.primaryColor,
                  ),
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) => toggleDarkMode(),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.list, color: Constants.primaryColor),
                  title: Text('My Recipes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyRecipesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Constants.primaryColor),
                  title: Text('Logout'),
                  onTap: logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
