import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'SongPage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();

  void initState() {
    super.initState();
    requestPermission();
  }

  requestPermission() async {
    // Web platform don't support permissions methods.
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  playSong(String? uri) {
    try {
      _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _player.play();
    } on Exception {
      print("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SongModel>>(
        // Default values:
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          // Loading content
          if (item.data == null) return const CircularProgressIndicator();

          // When you try "query" without asking for [READ] or [Library] permission
          // the plugin will return a [Empty] list.
          if (item.data!.isEmpty) return const Text("Nothing found!");

          // You can use [item.data!] direct or you can create a:
          // List<SongModel> songs = item.data!;
          return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () async {
                  // await _player.setAudioSource(
                  //     AudioSource.uri(Uri.parse(item.data![index].uri!)));
                  // _player.play();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SongPage(
                                songModel: item.data![index],
                                audioPlayer: _player,
                              )));
                },
                title: Text(item.data![index].title),
                subtitle: Text(item.data![index].artist ?? "No Artist"),
                trailing: const Icon(Icons.arrow_forward_rounded),
                // This Widget will query/load image. Just add the id and type.
                // You can use/create your own widget/method using [queryArtwork].
                leading: QueryArtworkWidget(
                  id: item.data![index].id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Icon(Icons.music_note),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
