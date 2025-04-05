import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song_bookmark.dart';
import '../models/playlist.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();
  
  var isPlaying = false.obs;
  var playIndex = 0.obs;
  var duration = ''.obs;
  var position = ''.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;
  var isLoading = false.obs;
  var currentIndex = 0.obs;  // For bottom navigation
  
  // Variables for bottom player
  var currentSong = ''.obs;
  var currentArtist = ''.obs;
  var currentUri = ''.obs;
  var songs = <SongModel>[].obs;  // Store all songs
  var currentSongModel = Rxn<SongModel>();  // Store current song model
  var currentSongIndex = 0.obs;

  // Bookmark management
  var bookmarks = <String, SongBookmark>{}.obs;
  RxMap<String, int> currentBookmarks = <String, int>{}.obs;
  // var currentBookmarks = <String, int>{}.obs;
  var isAddingBookmark = false.obs;
  var newBookmarkName = ''.obs;

  // Playlist management
  var playlists = <Playlist>[].obs;
  var isCreatingPlaylist = false.obs;
  var newPlaylistName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
    setupAudioPlayer();
    loadBookmarks();
    loadSongs();
    loadPlaylists();
  }

  Future<void> loadSongs() async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        songs.value = await audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
        );
      }
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  void setupAudioPlayer() {
    try {
      audioPlayer.playerStateStream.listen((state) {
        isPlaying.value = state.playing;
        if (state.processingState == ProcessingState.completed) {
          playNextSong();
        }
      });

      audioPlayer.durationStream.listen((d) {
        if (d != null) {
          duration.value = d.toString().split(".")[0];
          max.value = d.inSeconds.toDouble();
        }
      });

      audioPlayer.positionStream.listen((p) {
        position.value = p.toString().split(".")[0];
        value.value = p.inSeconds.toDouble();
      });

      audioPlayer.playbackEventStream.listen((event) {
        debugPrint('Playback event: $event');
      });

      audioPlayer.playerStateStream.listen((state) {
        debugPrint('Player state: $state');
      });
    } catch (e) {
      debugPrint('Error in setupAudioPlayer: $e');
    }
  }

  

  Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString('song_bookmarks');
      if (bookmarksJson != null) {
        final Map<String, dynamic> decoded = json.decode(bookmarksJson);
        bookmarks.value = decoded.map((key, value) => 
          MapEntry(key, SongBookmark.fromJson(value)));
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  Future<void> saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = json.encode(
        bookmarks.map((key, value) => MapEntry(key, value.toJson()))
      );
      await prefs.setString('song_bookmarks', bookmarksJson);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  void updateCurrentBookmarks() {
    if (currentUri.value.isNotEmpty) {
      currentBookmarks.value = bookmarks[currentUri.value]?.bookmarks ?? {};
    } else {
      currentBookmarks.value = {};
    }
    currentBookmarks.refresh();
  }

  void addBookmark(String name) {
    if (currentUri.value.isNotEmpty) {
      final timestamp = value.value.toInt();
      final bookmark = SongBookmark(
        songUri: currentUri.value,
        bookmarks: {
          ...(bookmarks[currentUri.value]?.bookmarks ?? {}),
          name: timestamp,
        },
      );
      bookmarks[currentUri.value] = bookmark;
      currentBookmarks[name] = timestamp;
      saveBookmarks();
      isAddingBookmark.value = false;
      newBookmarkName.value = '';
    }
  }

  void removeBookmark(String name) {
    if (currentUri.value.isNotEmpty && bookmarks.containsKey(currentUri.value)) {
      final currentBookmark = bookmarks[currentUri.value]!;
      final newBookmarks = Map<String, int>.from(currentBookmark.bookmarks)
        ..remove(name);
      
      if (newBookmarks.isEmpty) {
        bookmarks.remove(currentUri.value);
      } else {
        bookmarks[currentUri.value] = SongBookmark(
          songUri: currentUri.value,
          bookmarks: newBookmarks,
        );
      }
      
      currentBookmarks.remove(name);
      saveBookmarks();
    }
  }

  void jumpToBookmark(String name) {
    final timestamp = currentBookmarks[name];
    if (timestamp != null) {
      changeDurationtoSeconds(timestamp);
    }
  }

  changeDurationtoSeconds(seconds) {
    try {
      audioPlayer.seek(Duration(seconds: seconds));
    } catch (e) {
      debugPrint('Error in changeDurationtoSeconds: $e');
    }
  }

  Future<void> refreshSongs() async {
    try {
      isLoading.value = true;
      var status = await Permission.storage.request();
      if (status.isGranted) {
        songs.value = await audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
        );
      }
    } catch (e) {
      debugPrint('Error refreshing songs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playSong(String uri, int index) async {
    try {
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await audioPlayer.play();
      playIndex.value = index;
      await _updatePlayCount(uri);
      await _addToRecentlyPlayed(uri);
      currentUri.value = uri;
      updateCurrentBookmarks();
    } catch (e) {
      debugPrint('Error playing song: $e');
      Get.snackbar(
        'Error',
        'Failed to play the song',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updatePlayCount(String uri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songId = uri.split('/').last;
      final currentCount = prefs.getInt('play_count_$songId') ?? 0;
      await prefs.setInt('play_count_$songId', currentCount + 1);
    } catch (e) {
      debugPrint('Error updating play count: $e');
    }
  }

  Future<void> _addToRecentlyPlayed(String uri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songId = uri.split('/').last;
      final recentlyPlayed = prefs.getStringList('recently_played') ?? [];
      
      // Remove if already exists
      recentlyPlayed.remove(songId);
      
      // Add to beginning
      recentlyPlayed.insert(0, songId);
      
      // Keep only the last 50 songs
      if (recentlyPlayed.length > 50) {
        recentlyPlayed.removeLast();
      }
      
      await prefs.setStringList('recently_played', recentlyPlayed);
    } catch (e) {
      debugPrint('Error updating recently played: $e');
    }
  }

  void playNextSong() {
    if (songs.isEmpty) return;
    
    int nextIndex = (playIndex.value + 1) % songs.length;
    var nextSong = songs[nextIndex];
    
    if (nextSong.uri != null) {
      playSong(nextSong.uri!, nextIndex);
      currentSongModel.value = nextSong;
      updateCurrentSongInfo(
        nextSong.title ?? nextSong.displayNameWOExt,
        nextSong.artist ?? "Unknown Artist",
      );
    }
  }

  void playPreviousSong() {
    if (songs.isEmpty) return;
    
    int prevIndex = (playIndex.value - 1 + songs.length) % songs.length;
    var prevSong = songs[prevIndex];
    
    if (prevSong.uri != null) {
      playSong(prevSong.uri!, prevIndex);
      currentSongModel.value = prevSong;
      updateCurrentSongInfo(
        prevSong.title ?? prevSong.displayNameWOExt,
        prevSong.artist ?? "Unknown Artist",
      );
    }
  }

  updateCurrentSongInfo(String title, String artist) {
    debugPrint('Updating song info - Original title: $title');
    currentSong.value = title.replaceAll(' - Topic', '');
    debugPrint('Updated song title: ${currentSong.value}');
    currentArtist.value = artist;
  }

  pauseSong() async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      debugPrint('Error in pauseSong: $e');
    }
  }

  resumeSong() async {
    try {
      await audioPlayer.play();
    } catch (e) {
      debugPrint('Error in resumeSong: $e');
    }
  }

  stopSong() async {
    try {
      await audioPlayer.stop();
      currentSong.value = '';
      currentArtist.value = '';
      currentUri.value = '';
      currentBookmarks.value = {};
      currentSongModel.value = null;
    } catch (e) {
      debugPrint('Error in stopSong: $e');
    }
  }

  Future<bool> checkPermission() async {
    try {
      if (await Permission.storage.isGranted) {
        return true;
      }
      
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      
      return false;
    } catch (e) {
      debugPrint('Error in checkPermission: $e');
      return false;
    }
  }

  @override
  void onClose() {
    try {
      audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error in onClose: $e');
    }
    super.onClose();
  }

  // Playlist management methods
  Future<void> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString('playlists');
      if (playlistsJson != null) {
        final List<dynamic> decoded = json.decode(playlistsJson);
        playlists.value = decoded.map((json) => Playlist.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }
  }

  Future<void> savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = json.encode(playlists.map((p) => p.toJson()).toList());
      await prefs.setString('playlists', playlistsJson);
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      final playlist = Playlist(
        name: name,
        songIds: [],
        createdAt: DateTime.now(),
      );
      playlists.add(playlist);
      await savePlaylists();
      isCreatingPlaylist.value = false;
      newPlaylistName.value = '';
    } catch (e) {
      debugPrint('Error creating playlist: $e');
    }
  }

  Future<void> addSongToPlaylist(String songId, String playlistName) async {
    try {
      final playlistIndex = playlists.indexWhere((p) => p.name == playlistName);
      if (playlistIndex != -1) {
        final playlist = playlists[playlistIndex];
        if (!playlist.songIds.contains(songId)) {
          final updatedPlaylist = Playlist(
            name: playlist.name,
            songIds: [...playlist.songIds, songId],
            createdAt: playlist.createdAt,
          );
          playlists[playlistIndex] = updatedPlaylist;
          await savePlaylists();
        }
      }
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
    }
  }

  Future<void> removeSongFromPlaylist(String songId, String playlistName) async {
    try {
      final playlistIndex = playlists.indexWhere((p) => p.name == playlistName);
      if (playlistIndex != -1) {
        final playlist = playlists[playlistIndex];
        final updatedPlaylist = Playlist(
          name: playlist.name,
          songIds: playlist.songIds.where((id) => id != songId).toList(),
          createdAt: playlist.createdAt,
        );
        playlists[playlistIndex] = updatedPlaylist;
        await savePlaylists();
      }
    } catch (e) {
      debugPrint('Error removing song from playlist: $e');
    }
  }

  Future<void> deletePlaylist(String playlistName) async {
    try {
      playlists.removeWhere((p) => p.name == playlistName);
      await savePlaylists();
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
    }
  }
}
