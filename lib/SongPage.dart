import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongPage extends StatefulWidget {
  const SongPage(
      {super.key, required this.songModel, required this.audioPlayer});
  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  bool _isPlaying = true;
  Duration duration = Duration();
  Duration position = Duration();
  double now = 0.0;

  @override
  void initState() {
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      widget.audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(widget.songModel.uri!)));
      widget.audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    } on Exception {
      print("Error");
    }

    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });
  }

  void sliderThing(int sec) {
    Duration duration = Duration(seconds: sec);
    widget.audioPlayer.seek(duration);
    widget.audioPlayer.play();
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Page'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(20),
              height: 300,
              width: double.infinity,
              child: QueryArtworkWidget(
                keepOldArtwork: true,
                id: widget.songModel.id,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: const Icon(
                  Icons.music_note,
                  size: 200,
                ),
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.songModel.displayNameWOExt,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Slider(
              min: Duration(seconds: 0).inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (val) {
                setState(() {
                  sliderThing(val.toInt());
                });
              }),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    position.toString().split(".")[0],
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    duration.toString().split(".")[0],
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /*  IconButton(
                iconSize: 50,
                onPressed: () {},
                icon: const Icon(Icons.skip_previous),
              ), */
              ElevatedButton(
                onPressed: () {
                  if (_isPlaying) {
                    widget.audioPlayer.pause();
                    setState(() {
                      _isPlaying = false;
                    });
                  } else {
                    widget.audioPlayer.play();
                    setState(() {
                      _isPlaying = true;
                    });
                  }
                },
                child: _isPlaying
                    ? Icon(
                        Icons.pause,
                        size: 70,
                      )
                    : Icon(
                        Icons.play_arrow,
                        size: 70,
                      ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                  backgroundColor: MaterialStateProperty.all(
                      Colors.deepOrange), // <-- Button color
                  overlayColor:
                      MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.pressed))
                      return _isPlaying
                          ? Colors.grey
                          : Colors.green; // <-- Splash color
                  }),
                ),
              )
              /*  IconButton(
                iconSize: 50,
                onPressed: () {},
                icon: const Icon(Icons.skip_next),
              ), */
            ],
          )
        ],
      ),
    );
  }
}
