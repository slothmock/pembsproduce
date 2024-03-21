import 'package:flutter/material.dart';
import '../helpers/constants/colors.dart';

class AppDiv extends StatelessWidget {
  const AppDiv({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.divider,
    );
  }
}
