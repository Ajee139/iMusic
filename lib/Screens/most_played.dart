import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:imusic/Screens/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MostPlayed extends StatelessWidget {
  const MostPlayed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Most Played'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: OnAudioQuery().querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!;
          if (songs.isEmpty) {
            return const Center(child: Text('No songs found'));
          }

          // Get play counts from SharedPreferences
          return FutureBuilder<Map<String, int>>(
            future: _getPlayCounts(),
            builder: (context, playCountSnapshot) {
              if (!playCountSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final playCounts = playCountSnapshot.data!;
              
              // Sort songs by play count
              final sortedSongs = List<SongModel>.from(songs)
                ..sort((a, b) {
                  final countA = playCounts[a.id.toString()] ?? 0;
                  final countB = playCounts[b.id.toString()] ?? 0;
                  return countB.compareTo(countA);
                });

              return ListView.builder(
                itemCount: sortedSongs.length,
                itemBuilder: (context, index) {
                  final song = sortedSongs[index];
                  final playCount = playCounts[song.id.toString()] ?? 0;
                  
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
                    trailing: Text(
                      '$playCount plays',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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

  Future<Map<String, int>> _getPlayCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final playCounts = <String, int>{};
    
    // Get all keys that start with 'play_count_'
    final keys = prefs.getKeys().where((key) => key.startsWith('play_count_'));
    
    for (final key in keys) {
      final songId = key.replaceFirst('play_count_', '');
      final count = prefs.getInt(key) ?? 0;
      playCounts[songId] = count;
    }
    
    return playCounts;
  }
} 