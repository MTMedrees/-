import 'package:anached_denya/screens/edit_container_screen.dart';
import 'package:flutter/material.dart';

class AddCountainer extends StatefulWidget {
  final String names;
  final VoidCallback onDelete; // دالة الحذف
  const AddCountainer({super.key, required this.names, required this.onDelete});

  @override
  State<AddCountainer> createState() => _AddCountainerState();
}

class _AddCountainerState extends State<AddCountainer> {
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العنصر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // الغاء
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق رسالة التأكيد
              widget.onDelete(); // تنفيذ الحذف
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditContainerScreen(songData: {}),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _confirmDelete, // عرض رسالة التأكيد عند الحذف
                  icon: const Icon(Icons.delete, size: 25, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.names,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kufam',
                    ),
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
