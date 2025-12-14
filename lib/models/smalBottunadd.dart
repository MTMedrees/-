import 'package:flutter/material.dart';

class Smalbottunadd extends StatefulWidget {
  final IconData icon; // ← أيقونة قابلة للتغيير عند الاستدعاء
  final String number;

  const Smalbottunadd({
    super.key,
    required this.icon, // ← إضافة الباراميتر
    required this.number,
  });

  @override
  State<Smalbottunadd> createState() => _SmalbottunaddState();
}

class _SmalbottunaddState extends State<Smalbottunadd> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 70,
        height: 40,
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
            onPressed: () {},
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
                Spacer(),
                Text(
                  widget.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kufam',
                  ),
                ),
                Spacer(),
                Icon(
                  widget.icon, // ← الأيقونة من المستخدم
                  color: Colors.white,
                  size: 18,
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
