import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ukl_apk/pages/add_song_page.dart';
import 'song_list_page.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List playlists = [];
  bool loading = true;

  Future<void> fetchPlaylists() async {
    final url = Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists');
    final response = await http.get(url);

    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        playlists = data['data'];
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
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
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    title: Text(playlist['playlist_name']),
                    subtitle: Text("${playlist['song_count']} lagu"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => SongListPage(playlistId: playlist['uuid']),
                        ),
                      );
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddSongPage()),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
