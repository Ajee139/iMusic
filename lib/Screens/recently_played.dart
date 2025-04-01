import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:imusic/Screens/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyPlayed extends StatelessWidget {
  const RecentlyPlayed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Played'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: _getRecentlyPlayed(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songIds = snapshot.data!;
          if (songIds.isEmpty) {
            return const Center(child: Text('No recently played songs'));
          }

          return FutureBuilder<List<SongModel>>(
            future: OnAudioQuery().querySongs(
              sortType: SongSortType.TITLE,
              orderType: OrderType.ASC_OR_SMALLER,
            ),
            builder: (context, songsSnapshot) {
              if (!songsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allSongs = songsSnapshot.data!;
              final recentlyPlayedSongs = songIds
                  .map((id) => allSongs.firstWhere(
                        (song) => song.id.toString() == id,
                        orElse: () => allSongs.first,
                      ))
                  .toList();

              return ListView.builder(
                itemCount: recentlyPlayedSongs.length,
                itemBuilder: (context, index) {
                  final song = recentlyPlayedSongs[index];
                  return ListTile(
                    leading: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 50,
                      artworkWidth: 50,
                      nullArtworkWidget: const Icon(Icons.music_note),
                    ),
                    title: Text(
                      song.displayName ?? 
                      song.title ?? 
                      song.displayNameWOExt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist ?? 'Unknown Artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final controller = Get.find<PlayerController>();
                      controller.playSong(song.uri!, 0);
                      controller.currentSongModel.value = song;
                      controller.currentSongIndex.value = index;
                      Get.to(() => Player(data: song));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final recentlyPlayed = prefs.getStringList('recently_played') ?? [];
    return recentlyPlayed.take(50).toList(); // Limit to 50 songs
  }
} 