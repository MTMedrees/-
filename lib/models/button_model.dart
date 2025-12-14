import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SliderWidget extends StatefulWidget {
  final AudioPlayer player;
  final String url; // the audio URL or asset path
  const SliderWidget({super.key, required this.player, required this.url});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  bool isPlaying = false;
  Duration total = Duration.zero;
  Duration position = Duration.zero;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();

    // Set the audio source first
    widget.player.setSourceUrl(widget.url);

    // Listen to duration
    _durationSub = widget.player.onDurationChanged.listen((d) {
      setState(() => total = d);
    });

    // Listen to position
    _positionSub = widget.player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    // Listen to player state
    _stateSub = widget.player.onPlayerStateChanged.listen((state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });

    // Completion
    widget.player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  String fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Play/Pause button
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
          color: const Color(0xFF0B8F0F),
          onPressed: () async {
            if (isPlaying) {
              await widget.player.pause();
            } else {
              await widget.player.play(UrlSource(widget.url));
            }
          },
        ),

        // Current position
        Text(fmt(position), style: const TextStyle(fontSize: 14)),

        const SizedBox(width: 5),

        // Slider
        Expanded(
          child: Slider(
            value: (total.inMilliseconds > 0)
                ? (position.inMilliseconds / total.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  )
                : 0.0,
            onChanged: (v) {
              final newPos = Duration(
                milliseconds: (total.inMilliseconds * v).round(),
              );
              widget.player.seek(newPos);
              setState(() => position = newPos);
            },
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFF0B8F0F),
            inactiveColor: const Color.fromARGB(57, 11, 143, 15),
          ),
        ),

        const SizedBox(width: 10),

        // Total duration
        Text(fmt(total), style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
