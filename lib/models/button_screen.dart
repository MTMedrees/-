import 'package:flutter/material.dart';

class ButtonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed; // ممكن تكون null لتعطيل الزر

  const ButtonScreen({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed, // خليها اختيارية
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: double.infinity,
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
            onPressed: onPressed, // استخدمها مباشرة
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 30),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kufam',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
