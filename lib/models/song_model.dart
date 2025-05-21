class Song {
  final String title;
  final String artist;
  final String imageUrl;
  final Duration duration;

  Song({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.duration,
  });
}

class Playlist {
  final String name;
  final List<Song> songs;

  Playlist({required this.name, required this.songs});
}
