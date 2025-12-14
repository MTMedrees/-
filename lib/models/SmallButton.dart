import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  final IconData icon;
  final String number;
  final double iconSize;
  final double height;
  final VoidCallback? onPressed;

  const SmallButton({
    super.key,
    required this.icon,
    required this.number,
    this.iconSize = 16,
    this.height = 40,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 70,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF065F08), Color(0xFF0B8F0F), Color(0xFF065F08)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(144, 0, 0, 0),
                offset: Offset(0, 0),
                blurRadius: 8,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kufam',
                  ),
                ),
                const Spacer(),
                Icon(icon, color: Colors.white, size: iconSize),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
