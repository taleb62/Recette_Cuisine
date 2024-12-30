import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pifront/constants.dart';
import 'package:pifront/ui/Add_Screen.dart';
import 'package:pifront/ui/screens/favorite_page.dart';
import 'package:pifront/ui/screens/home_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  int _bottomNavIndex = 0;
  bool isDarkMode = false; // State for dark mode toggle

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }

      // Fetch user data from the 'user' table
      final response = await supabase
          .from('user')
          .select('name, phone_number, profile_image')
          .eq('id', currentUser.id)
          .single();

      if (response != null) {
        // Get email from Supabase Auth
        final email = currentUser.email;

        // Fetch public URL for profile image if available
        final profileImageUrl = response['profile_image'] != null
            ? supabase.storage.from('photos_bucket').getPublicUrl(response['profile_image'])
            : null;

        response['email'] = email; // Add email to response
        response['profile_image_url'] = profileImageUrl; // Add public URL to response
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
      Get.offAllNamed('/login'); // Navigate to login screen
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
                color: Constants.blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.dark_mode_rounded,
                color: Constants.blackColor,
                size: 30.0,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // Open the drawer
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
                  builder: (context) => Add_Screen())); // Navigate to Add_Screen
        },
        child: Image.asset(
          'assets/images/plus.png',
          height: 30.0,
        ),
        backgroundColor:Color(0xFF493AD5),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Color(0xFF493AD5),
        activeColor: Color(0xFF493AD5),
        inactiveColor: Colors.black.withOpacity(.5),
        icons: [Icons.home, Icons.favorite],
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
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
