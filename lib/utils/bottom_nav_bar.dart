import 'package:flutter/material.dart';
import 'package:aqua_sentinel/widgets/navBar_items.dart';

class BottomNavBar extends StatelessWidget {
  final selectedIndex;
  final void Function(int) selectButton;
  BottomNavBar({required this.selectedIndex, required this.selectButton});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.white,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NavBarItem(
              label: 'Dashboard',
              iconName: Icons.dashboard,
              isActive: selectedIndex == 0 ? true : false,
              itemNumber: 0,
              selectButton: selectButton,
            ),
            NavBarItem(
              label: 'Billing',
              iconName: Icons.receipt,
              isActive: selectedIndex == 1 ? true : false,
              itemNumber: 1,
              selectButton: selectButton,
            ),
            NavBarItem(
              label: 'Alerts',
              iconName: Icons.notifications,
              isActive: selectedIndex == 2 ? true : false,
              itemNumber: 2,
              selectButton: selectButton,
            ),
            NavBarItem(
              label: 'Profile',
              iconName: Icons.person,
              isActive: selectedIndex == 3 ? true : false,
              itemNumber: 3,
              selectButton: selectButton,
            ),
          ],
        ),
      ),
    );
  }
}

//
// BottomNavigationBar(
// // The items for the navigation bar
// items: const <BottomNavigationBarItem>[
// // Dashboard Item
// BottomNavigationBarItem(
// icon: Icon(Icons.dashboard), // Use a grid icon for Dashboard
// label: 'Dashboard',
// ),
// // Billing Item
// BottomNavigationBarItem(
// icon: Icon(Icons.receipt), // Use a receipt/bill icon for Billing
// label: 'Billing',
// ),
// // Alerts Item
// BottomNavigationBarItem(
// icon: Icon(Icons.notifications), // Use a bell icon for Alerts
// label: 'Alerts',
// ),
// // Profile Item
// BottomNavigationBarItem(
// icon: Icon(Icons.person), // Use a person icon for Profile
// label: 'Profile',
// ),
// ],
// // Set the currently selected item
// currentIndex: _selectedIndex,
// // Define the color scheme/style
// selectedItemColor: Colors.blue, // The color for the active item
// unselectedItemColor: Colors.grey, // Color for inactive items
// // Important for 4 or more items: set the type to fixed
// type: BottomNavigationBarType.fixed,
// // The callback function when an item is tapped
// onTap: (index) {
// setState(() {
// _selectedIndex = index;
// });
// },
// )
