import 'dart:io';
import 'package:anached_denya/models/SmallButton.dart';
import 'package:anached_denya/models/button_screen.dart';
import 'package:anached_denya/models/widget_camel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddContainerScreen extends StatefulWidget {
  final Map<String, dynamic>? songData;

  const AddContainerScreen({super.key, this.songData});

  @override
  State<AddContainerScreen> createState() => _AddContainerScreenState();
}

class _AddContainerScreenState extends State<AddContainerScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final wordsController = TextEditingController();
  final notesController = TextEditingController();

  int? songId; // null = إضافة، غير ذلك = تعديل

  bool songAdded = false;
  String? songPath;

  final AudioPlayer audioPlayer = AudioPlayer();
  Duration total = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  bool isSaving = false; // حالة التحميل عند الحفظ

  @override
  void initState() {
    super.initState();

    if (widget.songData != null) {
      songId = widget.songData!['id'];
      nameController.text = widget.songData!['name'] ?? '';
      wordsController.text = widget.songData!['words'] ?? '';
      notesController.text = widget.songData!['notes'] ?? '';
      songPath = widget.songData!['songPath'];
      songAdded = songPath != null;
    }

    audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) setState(() => total = d);
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) setState(() => position = p);
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          position = Duration.zero;
          isPlaying = false;
        });
      }
    });
  }

  Future<void> seekForward(int seconds) async {
    final target = position + Duration(seconds: seconds);
    await audioPlayer.seek(target);
  }

  Future<void> seekBackward(int seconds) async {
    final back = position - Duration(seconds: seconds);
    await audioPlayer.seek(back < Duration.zero ? Duration.zero : back);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    nameController.dispose();
    wordsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return "$m:$s";
  }

  // دالة الحفظ (رفع + إدخال/تعديل)
  Future<void> _saveSong() async {
    if (isPlaying) await audioPlayer.stop();

    setState(() => isSaving = true);

    try {
      String? fileUrl;

      // رفع ملف الصوت إن وُجد
      if (songPath != null && songPath!.isNotEmpty) {
        final fileBytes = await File(songPath!).readAsBytes();
        final fileName = 'song_${DateTime.now().millisecondsSinceEpoch}.mp3';

        await supabase.storage
            .from('song')
            .uploadBinary(
              fileName,
              fileBytes,
              fileOptions: const FileOptions(contentType: 'audio/mpeg'),
            );

        fileUrl = supabase.storage.from('song').getPublicUrl(fileName);
      }

      // بيانات الجدول
      Map<String, dynamic> data = {
        'name': nameController.text,
        'words': wordsController.text,
        'notes': notesController.text,
        'file_url': fileUrl,
      };

      late final List<Map<String, dynamic>> result;

      if (songId == null) {
        // إضافة جديدة
        result = await supabase.from('Song').insert(data).select();
      } else {
        // احتفظ بالرابط القديم لو لم يرفع ملف جديد
        if (fileUrl == null && widget.songData?['file_url'] != null) {
          data['file_url'] = widget.songData!['file_url'];
        }

        result = await supabase
            .from('Song')
            .update(data)
            .eq('id', songId!)
            .select();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: const Color.fromARGB(255, 25, 40, 46),
          content: Center(
            child: Text(
              'تم الحفظ بنجاح',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Rubik',
              ),
            ),
          ),
        ),
      );

      Navigator.pop(context, result[0]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 25, 40, 46),
          content: Center(
            child: Text(
              'حدث خطأ عند حفظ البيانات: $e',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Rubik',
              ),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = songId != null;

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
            isEdit ? 'تعديل أنشودة' : 'أضــافـة أنـشودة',
            style: const TextStyle(color: Colors.white, fontFamily: 'Kufam'),
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: widgetKamel(
                    names: 'أسم الأنشودة',
                    controller: nameController,
                    line: 1,
                  ),
                ),

                // كلمات الأنشودة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30,
                        right: 8,
                        left: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 30,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF065F08),
                                    Color(0xFF0B8F0F),
                                    Color(0xFF065F08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
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
                                  String text = wordsController.text;
                                  List<String> lines = text
                                      .split(RegExp(r'\n|\.'))
                                      .map((l) => l.trim())
                                      .where((l) => l.isNotEmpty)
                                      .toList();
                                  wordsController.text = lines.join('\n');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.format_align_left,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'تنسيق الكلمات',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Kufam',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Text(
                            'كلمات الأنشودة',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 83, 5),
                              fontFamily: 'Kufam',
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8,

                        bottom: 20,
                      ),
                      child: widgetKamel(
                        names: '',
                        controller: wordsController,
                        line: 13,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: widgetKamel(
                    names: "ملاحظات",
                    controller: notesController,
                    line: 5,
                  ),
                ),
                const SizedBox(height: 20),

                // زر إضافة الأنشودة (ملف الصوت)
                if (!songAdded)
                  ButtonScreen(
                    icon: Icons.music_note,
                    title: "إضــــافـة   أنــــشودة",
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp3', 'wav', 'm4a'],
                      );

                      if (result != null && result.files.isNotEmpty) {
                        songPath = result.files.first.path!;
                        songAdded = true;

                        setState(() {});

                        await audioPlayer.setSource(
                          DeviceFileSource(songPath!),
                        );
                        await audioPlayer.resume();
                        setState(() => isPlaying = true);
                      }
                    },
                  ),

                // مشغل الصوت
                if (songAdded)
                  Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 30,
                              color: const Color(0xFF0B8F0F),
                            ),
                            onPressed: () async {
                              if (isPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer.setSource(
                                  DeviceFileSource(songPath!),
                                );
                                await audioPlayer.resume();
                              }
                              setState(() => isPlaying = !isPlaying);
                            },
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                Slider(
                                  value: position.inSeconds.toDouble(),
                                  max: total.inSeconds == 0
                                      ? 1
                                      : total.inSeconds.toDouble(),
                                  min: 0,
                                  activeColor: const Color(0xFF0B8F0F),
                                  inactiveColor: const Color.fromARGB(
                                    57,
                                    11,
                                    143,
                                    15,
                                  ),
                                  onChanged: (value) async {
                                    await audioPlayer.seek(
                                      Duration(seconds: value.toInt()),
                                    );
                                  },
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Text(
                                        _formatDuration(position),
                                        style: const TextStyle(
                                          color: Color(0xFF0B8F0F),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        _formatDuration(total),
                                        style: const TextStyle(
                                          color: Color(0xFF0B8F0F),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SmallButton(
                            icon: Icons.fast_rewind,
                            number: '10',
                            onPressed: () => seekBackward(10),
                          ),
                          SmallButton(
                            icon: Icons.fast_rewind,
                            number: '5',
                            iconSize: 18,
                            height: 40,
                            onPressed: () => seekBackward(5),
                          ),
                          SmallButton(
                            icon: Icons.fast_forward,
                            number: '5',
                            iconSize: 18,
                            height: 40,
                            onPressed: () => seekForward(5),
                          ),
                          SmallButton(
                            icon: Icons.fast_forward,
                            number: '10',
                            onPressed: () => seekForward(10),
                          ),
                        ],
                      ),
                    ],
                  ),

                // زر حفظ
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: ButtonScreen(
                    icon: Icons.save,
                    title: isSaving ? '...جاري الحفظ' : 'حــفـظ',
                    onPressed: isSaving
                        ? null
                        : _saveSong, // _saveSong هي Future<void> async
                  ),
                ),
              ],
            ),
          ),

          // Overlay عند الحفظ (اختياري)
          if (isSaving)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
