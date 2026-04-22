import 'package:flutter/material.dart';


class RowTile extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final Color color;

  const RowTile({
    required this.onTap,
    required this.title,
    required this.icon,
    super.key,
    this.color = const Color(0xFF0F172A),
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 8),
                      Text(
                        title,

                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_right_outlined),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: Colors.grey.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ],
    );
  }
}
