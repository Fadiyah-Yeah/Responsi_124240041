import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SiteFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const SiteFilter({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = ['All','European Spaceflight', 'SpacePolicyOnline.com', 'Arstechnica', 'NASA', 'Space Scout'];
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: options.map((value) {
          final active = selected == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(value),
              selected: active,
              onSelected: (_) => onSelected(value),
              selectedColor: AppColors.sage,
              backgroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.sand),
              labelStyle: TextStyle(color: active ? Colors.white : AppColors.ink),
            ),
          );
        }).toList(),
      ),
    );
  }
}