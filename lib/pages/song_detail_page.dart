import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SongDetailPage extends StatefulWidget {
  final String songId;
  const SongDetailPage({super.key, required this.songId, required song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  Map<String, dynamic>? songData;
  bool loading = true;
  YoutubePlayerController? _controller;
  String? error;

  Future<void> fetchSongDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song/${widget.songId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final videoId = YoutubePlayer.convertUrlToId(data['data']['source']);
          if (videoId != null) {
            _controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(autoPlay: false),
            );
          }
          setState(() {
            songData = data['data'];
            loading = false;
          });
        } else {
          setState(() {
            error = "Data tidak ditemukan.";
            loading = false;
          });
        }
      } else {
        setState(() {
          error = "Gagal mengambil data. Status: ${response.statusCode}";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Terjadi kesalahan: $e";
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSongDetail();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Lagu')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : songData == null
              ? const Center(child: Text('Data kosong.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_controller != null)
                      YoutubePlayer(controller: _controller!),
                    const SizedBox(height: 10),
                    Text(
                      songData!['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Artis: ${songData!['artist']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(songData!['description']),
                    const SizedBox(height: 10),
                    Text("❤️ ${songData!['likes']} likes"),
                    const SizedBox(height: 16),
                    const Text(
                      "Komentar:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(songData!['comments'].length, (index) {
                      final comment = songData!['comments'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          tileColor: Colors.grey.shade100,
                          title: Text(comment['creator']),
                          subtitle: Text(comment['comment_text']),
                          trailing: Text(comment['createdAt']),
                        ),
                      );
                    }),
                  ],
                ),
              ),
    );
  }
}
