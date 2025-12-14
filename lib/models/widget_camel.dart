import 'package:flutter/material.dart';

class widgetKamel extends StatelessWidget {
  final String names;
  final int line;
  final TextEditingController controller;
  final bool readOnly; // ← تمت الإضافة

  const widgetKamel({
    super.key,
    required this.names,
    required this.line,
    required this.controller,
    this.readOnly = false, // ← القيمة الافتراضية
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(
            names,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 4, 83, 5),
              fontFamily: 'Kufam',
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 9),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(94, 0, 0, 0),
                offset: Offset(0, 0),
                blurRadius: 5,
              ),
            ],
          ),

          child: TextField(
            controller: controller,
            maxLines: line,
            readOnly: readOnly, // ← تفعيل الإقفال
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(148, 19, 102, 22),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color.fromARGB(148, 19, 102, 22),
                  width: 2.5,
                ),
              ),
            ),
            cursorColor: Colors.green,
            style: const TextStyle(
              color: Color.fromARGB(255, 3, 70, 4),
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
