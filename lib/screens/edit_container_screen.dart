import 'package:anached_denya/screens/full_lyrics_screen.dart';
import 'package:flutter/material.dart';
import 'package:anached_denya/models/SmallButton.dart';
import 'package:anached_denya/models/widget_camel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:anached_denya/screens/add_container_screen.dart';

class EditContainerScreen extends StatefulWidget {
  final Map<String, dynamic> songData;

  const EditContainerScreen({super.key, required this.songData});

  @override
  State<EditContainerScreen> createState() => _EditContainerScreenState();
}

class _EditContainerScreenState extends State<EditContainerScreen> {
  late TextEditingController nameController;
  late TextEditingController wordsController;
  late TextEditingController notesController;

  final AudioPlayer audioPlayer = AudioPlayer();
  Duration total = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.songData['name'] ?? '');
    wordsController = TextEditingController(
      text: widget.songData['words'] ?? '',
    );
    notesController = TextEditingController(
      text: widget.songData['notes'] ?? '',
    );

    audioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => total = d);
    });

    audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => position = p);
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  Future<void> seekForward(int seconds) async {
    final current = await audioPlayer.getCurrentPosition() ?? Duration.zero;
    final target = current + Duration(seconds: seconds);
    audioPlayer.seek(target);
  }

  Future<void> seekBackward(int seconds) async {
    final current = await audioPlayer.getCurrentPosition() ?? Duration.zero;
    final target = current - Duration(seconds: seconds);
    audioPlayer.seek(target < Duration.zero ? Duration.zero : target);
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return "$m:$s";
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    nameController.dispose();
    wordsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // رابط الملف من Supabase
    final String? fileUrl = widget.songData['file_url'] as String?;

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
        title: const Center(
          child: Text(
            'الـتـفـاصــيـل',
            style: TextStyle(color: Colors.white, fontFamily: 'Kufam'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedSong = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContainerScreen(
                    songData: {
                      'id': widget.songData['id'],
                      'name': nameController.text,
                      'words': wordsController.text,
                      'notes': notesController.text,
                      'file_url': fileUrl,
                    },
                  ),
                ),
              );

              if (updatedSong != null) {
                setState(() {
                  nameController.text = updatedSong['name'] ?? '';
                  wordsController.text = updatedSong['words'] ?? '';
                  notesController.text = updatedSong['notes'] ?? '';
                });

                // رجّع البيانات المحدّثة للـ HomeScreen
                Navigator.pop(context, updatedSong);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widgetKamel(
                names: 'أسم الأنشودة',
                controller: nameController,
                line: 1,
                readOnly: true,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر يفتح صفحة FullLyricsScreen
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 30.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.zoom_out_map_sharp, // أو أيقونة أخرى تحبها
                      color: Color(0xFF065F08),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullLyricsScreen(
                            title: 'كلمات الأنشودة',
                            lyrics: wordsController.text,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0, right: 8),
                  child: const Text(
                    'كلمات الأنشودة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 83, 5),
                      fontFamily: 'Kufam',
                    ),
                  ),
                ),
              ],
            ),

            // حقل الكلمات نفسه (معاينة في نفس الصفحة)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8),
              child: widgetKamel(
                names: '',
                controller: wordsController,
                line: 13, // عدد أسطر في صفحة التفاصيل (يمكن تعديله)
                readOnly: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8,
                top: 30,
                bottom: 20,
              ),
              child: widgetKamel(
                names: 'ملاحظات',
                controller: notesController,
                line: 4,
                readOnly: true,
              ),
            ),

            // مشغل الصوت لو فيه رابط ملف
            if (fileUrl != null && fileUrl.isNotEmpty) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 30,
                        color: const Color(0xFF0B8F0F),
                      ),
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.play(UrlSource(fileUrl));
                        }
                        setState(() => isPlaying = !isPlaying);
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: total.inSeconds.toDouble() == 0
                              ? 1
                              : total.inSeconds.toDouble(),
                          min: 0,
                          activeColor: const Color(0xFF0B8F0F),
                          inactiveColor: const Color.fromARGB(57, 11, 143, 15),
                          onChanged: (value) async {
                            final newPos = Duration(seconds: value.toInt());
                            await audioPlayer.seek(newPos);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
