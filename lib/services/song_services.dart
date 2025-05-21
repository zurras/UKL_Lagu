import '../models/song_model.dart';

class SongService {
  final List<Song> _songs = [];

  List<Song> getAllSongs() {
    return _songs;
  }

  void addSong(Song song) {
    _songs.add(song);
  }

  void removeSong(Song song) {
    _songs.remove(song);
  }
}
