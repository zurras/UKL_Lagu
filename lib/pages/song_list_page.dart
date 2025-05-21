import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ukl_apk/pages/add_song_page.dart';
import 'package:ukl_apk/pages/song_detail_page.dart';

class SongListPage extends StatefulWidget {
  final String playlistId;
  const SongListPage({super.key, required this.playlistId});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List songs = [];
  List likedSongs = [];
  List filteredSongs = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final uri = Uri.parse(
      'https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song-list/${widget.playlistId}',
    );
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        songs = data['data'];
        filteredSongs = data['data'];
        loading = false;
      });
    }
  }

  void filterSongs(String query) {
    setState(() {
      searchQuery = query;
      filteredSongs =
          songs.where((song) {
            final title = song['title'].toString().toLowerCase();
            final artist = song['artist'].toString().toLowerCase();
            return title.contains(query.toLowerCase()) ||
                artist.contains(query.toLowerCase());
          }).toList();
    });
  }

  void toggleLike(String songId) {
    setState(() {
      if (likedSongs.contains(songId)) {
        likedSongs.remove(songId);
      } else {
        likedSongs.add(songId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        title: Text(
          'Daftar Lagu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.shade300,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddSongPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari lagu...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: filterSongs,
            ),
          ),
        ),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = filteredSongs[index];
                  final thumbnailUrl =
                      'https://learn.smktelkom-mlg.sch.id/ukl2/thumbnail/${song['thumbnail']}';
                  final isLiked = likedSongs.contains(song['uuid']);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          thumbnailUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.music_note, size: 40),
                        ),
                      ),
                      title: Text(
                        song['title'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        song['artist'],
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => toggleLike(song['uuid']),
                          ),
                          Text(
                            '${song['likes']}',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SongDetailPage(
                                  song: song,
                                  songId: song['uuid'].toString(),
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
