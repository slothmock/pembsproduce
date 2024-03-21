import 'package:flutter/material.dart';
import '../helpers/constants/colors.dart';
import '../pages/profile.dart';
import '../pages/shop_map.dart';

class PPBottomAppBar extends StatelessWidget {
  const PPBottomAppBar({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.grey[700],
      selectedItemColor: AppColors.primary,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      currentIndex: index,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ShopMapPage(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, a, __, c) => FadeTransition(
                opacity: a,
                child: c,
              ),
            ));
          case 1:
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ProfilePage(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, a, __, c) => FadeTransition(
                opacity: a,
                child: c,
              ),
            ));

          default:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined, color: Colors.white),
            label: "Farmshops",
            activeIcon: Icon(Icons.food_bank)),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.white),
            label: "Profile",
            activeIcon: Icon(Icons.person)),
      ],
    );
  }
}
