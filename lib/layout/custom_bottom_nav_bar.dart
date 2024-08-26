import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/account_info/account.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserAccountPage()),
          );
        } else {
          onTap(index); // Continue with the original onTap logic
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), // Changed icon to person to represent account
          label: 'Account',          // Changed label to Account
        ),
      ],
    );
  }
}
