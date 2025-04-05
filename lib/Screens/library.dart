import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imusic/consts/colors.dart';
import 'package:imusic/Screens/all_songs.dart';
import 'package:imusic/Screens/recently_added.dart';
import 'package:imusic/Screens/most_played.dart';
import 'package:imusic/Screens/recently_played.dart';
import 'package:imusic/Screens/playlists.dart';
import 'package:imusic/controllers/playerController.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All Songs Section
              _buildSection(
                context,
                'All Songs',
                Icons.music_note,
                () => Get.to(() => const AllSongs()),
              ),
              const SizedBox(height: 16),
              
              // Most Played Section
              _buildSection(
                context,
                'Most Played',
                Icons.favorite,
                () => Get.to(() => const MostPlayed()),
              ),
              const SizedBox(height: 16),
              
              // Recently Added Section
              _buildSection(
                context,
                'Recently Added',
                Icons.new_releases,
                () => Get.to(() => const RecentlyAdded()),
              ),
              const SizedBox(height: 16),
              
              // Recently Played Section
              _buildSection(
                context,
                'Recently Played',
                Icons.history,
                () => Get.to(() => const RecentlyPlayed()),
              ),
              const SizedBox(height: 16),
              
              // Playlists Section
              _buildSection(
                context,
                'Playlists',
                Icons.playlist_play,
                () => Get.to(() => const Playlists()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to create new playlist
          _showCreatePlaylistDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final controller = Get.find<PlayerController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.createPlaylist(nameController.text);
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Playlist created successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
} 