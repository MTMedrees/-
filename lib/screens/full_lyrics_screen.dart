import 'package:flutter/material.dart';

class FullLyricsScreen extends StatelessWidget {
  final String title;
  final String lyrics;

  const FullLyricsScreen({
    super.key,
    required this.title,
    required this.lyrics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF065F08),
                Color.fromARGB(211, 9, 124, 13),
                Color(0xFF065F08),
              ],
            ),
          ),
        ),
        title: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontFamily: 'Kufam'),
          ),
        ),
      ),
      body: Container(
        // ياخد كل مساحة الشاشة تحت الـ AppBar
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Text(
            lyrics,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF065F08),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Rubik',
              height: 2,
            ),
          ),
        ),
      ),
    );
  }
}
