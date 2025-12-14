import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anached_denya/screens/add_container_screen.dart';
import 'package:anached_denya/screens/edit_container_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> songsList = [];
  List<Map<String, dynamic>> filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _onRefresh() async {
    await _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final response = await supabase.from('Song').select();
      final data = List<Map<String, dynamic>>.from(response);

      setState(() {
        songsList = data;
        filteredSongs = List.from(songsList);
      });
    } catch (e) {
      debugPrint('Error loading songs: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحميل الأناشيد: $e'),
          backgroundColor: const Color.fromARGB(255, 25, 40, 46),
        ),
      );
    }
  }

  void _openAddSongScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContainerScreen()),
    );

    if (result != null) {
      setState(() {
        songsList.add(result);
        _filterSongs(searchController.text);
      });
    }
  }

  void _filterSongs(String query) {
    setState(() {
      filteredSongs = songsList
          .where(
            (song) => song['name'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  void _confirmDelete(Map<String, dynamic> song) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 6, 61, 7),
              width: 1,
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFF224E4D), Color(0xff25956B), Color(0xFF24444F)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'هل أنت متأكد من حذف هذا العنصر؟',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik',
                  fontSize: 17,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // لا
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 29, 55, 63),

                              Color.fromARGB(255, 30, 117, 85),

                              Color(0xFF24444F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: const Border(
                            top: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                            left: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                            right: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'لا',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kufam',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // نعم
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        try {
                          await supabase
                              .from('Song')
                              .delete()
                              .eq('id', song['id']);

                          setState(() {
                            songsList.remove(song);
                            _filterSongs(searchController.text);
                          });
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل الحذف: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF224E4D),

                              Color.fromARGB(255, 30, 117, 85),

                              Color.fromARGB(255, 29, 55, 63),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: const Border(
                            top: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                            left: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                            right: BorderSide(
                              color: Color.fromARGB(255, 6, 61, 7),
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'نعم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kufam',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff21333A),
      appBar: AppBar(
        backgroundColor: const Color(0xff21333A),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kufam',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF366259), Color.fromARGB(255, 43, 82, 74)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterSongs,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '...البحث عن الأناشيد',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // القائمة
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF376259),
              onRefresh: _onRefresh,
              child: filteredSongs.isEmpty
                  ? ListView(
                      children: const [
                        Center(
                          child: Text(
                            'لا توجد أناشيد حتى الآن',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Kufam',
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 6.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff25956B),
                                        Color(0xff25956B),
                                        Color(0xFF246257),
                                        Color(0xFF224E4D),
                                        Color(0xFF24444F),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(144, 0, 0, 0),
                                        offset: Offset(0, 0),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () async {
                                      final updatedSong = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditContainerScreen(
                                                songData: song,
                                              ),
                                        ),
                                      );

                                      if (updatedSong != null) {
                                        setState(() {
                                          final i = songsList.indexWhere(
                                            (s) => s['id'] == updatedSong['id'],
                                          );
                                          if (i != -1) {
                                            songsList[i] = updatedSong;
                                          }
                                          _filterSongs(searchController.text);
                                        });
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        // أيقونة الحذف الصغيرة يمين/يسار حسب التصميم
                                        IconButton(
                                          onPressed: () => _confirmDelete(song),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Text(
                                              song['name'] ?? '',
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),

      // زر إضافة أنشودة أسفل اليمين/المنتصف تقريبًا
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 15),
            FloatingActionButton(
              onPressed: _openAddSongScreen,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      Color(0xff25956B), // فاتح في المنتصف
                      Color.fromARGB(255, 24, 99, 71),
                      Color.fromARGB(255, 13, 48, 35),
                      Color.fromARGB(255, 7, 17, 17), // غامق عند الأطراف
                    ],
                    stops: [0.2, 0.5, 0.75, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),

                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.add, size: 22, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
