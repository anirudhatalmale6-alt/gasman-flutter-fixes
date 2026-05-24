import 'package:flutter/material.dart';

class AnimatedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final List<String> labels;

  const AnimatedNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.icons,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final bool isSelected = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        icons[index],
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration:
                      const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 12 : 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      child: Text(labels[index]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
