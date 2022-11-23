import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessground/chessground.dart';

import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/widgets/player.dart';

import '../../authentication/ui/auth_widget.dart';
import '../data/tv_repository.dart';
import './tv_screen_controller.dart';

class TvScreen extends StatelessWidget {
  const TvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Lichess TV'), actions: const [
        AuthWidget(),
      ]),
      body: Center(
        child: Consumer(
          builder: (_, WidgetRef ref, __) {
            final tvFeed = ref.watch(tvFeedProvider);
            final tvState = ref.watch(tvScreenControllerProvider);
            return tvFeed.when(
              data: (_) {
                final topPlayer = tvState.orientation == Side.white
                    ? tvState.players[Side.black]
                    : tvState.players[Side.white];
                final bottomPlayer = tvState.orientation == Side.white
                    ? tvState.players[Side.white]
                    : tvState.players[Side.black];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    topPlayer != null
                        ? Player(
                            name: topPlayer.name,
                            title: topPlayer.title,
                            rating: topPlayer.rating,
                            clock: Duration(seconds: topPlayer.seconds),
                            active: tvState.isGameOngoing &&
                                tvState.turn == topPlayer.side)
                        : const SizedBox.shrink(),
                    Board(
                      interactableSide: InteractableSide.none,
                      settings:
                          const Settings(animationDuration: Duration.zero),
                      size: screenWidth,
                      orientation: tvState.orientation,
                      fen: tvState.fen,
                      lastMove: tvState.lastMove,
                    ),
                    bottomPlayer != null
                        ? Player(
                            name: bottomPlayer.name,
                            title: bottomPlayer.title,
                            rating: bottomPlayer.rating,
                            clock: Duration(seconds: bottomPlayer.seconds),
                            active: tvState.isGameOngoing &&
                                tvState.turn == bottomPlayer.side)
                        : const SizedBox.shrink(),
                  ],
                );
              },
              loading: () => Board(
                interactableSide: InteractableSide.none,
                size: screenWidth,
                orientation: Side.white,
                fen: kEmptyFen,
              ),
              error: (_, __) => const Text('Could not load TV stream.'),
            );
          },
        ),
      ),
    );
  }
}
