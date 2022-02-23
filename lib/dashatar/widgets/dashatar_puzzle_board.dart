import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nftpuzzlefun/audio_control/audio_control.dart';
import 'package:nftpuzzlefun/dashatar/bloc/collections_bloc.dart';
import 'package:nftpuzzlefun/dashatar/dashatar.dart';
import 'package:nftpuzzlefun/helpers/helpers.dart';
import 'package:nftpuzzlefun/layout/layout.dart';
import 'package:nftpuzzlefun/puzzle/puzzle.dart';
import 'package:nftpuzzlefun/timer/timer.dart';

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

/// {@template dashatar_puzzle_board}
/// Displays the board of the puzzle in a [Stack] filled with [tiles].
/// {@endtemplate}
class DashatarPuzzleBoard extends StatefulWidget {
  /// {@macro dashatar_puzzle_board}
  const DashatarPuzzleBoard({
    Key? key,
    required this.tiles,
  }) : super(key: key);

  /// The tiles to be displayed on the board.
  final List<Widget> tiles;

  @override
  State<DashatarPuzzleBoard> createState() => _DashatarPuzzleBoardState();
}

class _DashatarPuzzleBoardState extends State<DashatarPuzzleBoard> {
  Timer? _completePuzzleTimer;

  @override
  void dispose() {
    _completePuzzleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artwork = context.select((ArtworkBloc bloc) => bloc.state.artwork);
    final artworkOriginalImageSizes =
    context.select((ArtworkBloc bloc) => bloc.state.artworkOriginalImageSizes);

    final artworkOriginalImageDimensions = artworkOriginalImageSizes[artwork];
    final artworkOriginalImageWidth = artworkOriginalImageDimensions.item1;
    final artworkOriginalImageHeight = artworkOriginalImageDimensions.item2;

    var newHeightSmall = _BoardSize.small;
    var newHeightMedium = _BoardSize.medium;
    var newHeightLarge =  _BoardSize.large;
    var newWidthSmall = _BoardSize.small;
    var newWidthMedium = _BoardSize.medium;
    var newWidthLarge = _BoardSize.large;
    if (artworkOriginalImageWidth >= artworkOriginalImageHeight) {
      // ow / oh * nw = nh
      newHeightSmall = artworkOriginalImageHeight / artworkOriginalImageWidth * _BoardSize.small;
      newHeightMedium = artworkOriginalImageHeight / artworkOriginalImageWidth * _BoardSize.medium;
      newHeightLarge = artworkOriginalImageHeight / artworkOriginalImageWidth * _BoardSize.large;
      // debugPrint('newHeightLarge $newHeightLarge');
    } else {
      newWidthSmall = artworkOriginalImageWidth / artworkOriginalImageHeight * _BoardSize.small;
      newWidthMedium = artworkOriginalImageWidth / artworkOriginalImageHeight * _BoardSize.medium;
      newWidthLarge = artworkOriginalImageWidth / artworkOriginalImageHeight * _BoardSize.large;
      // debugPrint('newWidthLarge $newWidthLarge');
    }


    return BlocListener<PuzzleBloc, PuzzleState>(
      listener: (context, state) async {
        // NOTE: use this to test success page
        // if (state.puzzleStatus == PuzzleStatus.complete || true == true) {
        if (state.puzzleStatus == PuzzleStatus.complete) {
          _completePuzzleTimer =
              Timer(const Duration(milliseconds: 370), () async {
            await showAppDialog<void>(
              context: context,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: context.read<DashatarThemeBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<ArtworkBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<CollectionsBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<PuzzleBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<TimerBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<AudioControlBloc>(),
                  ),
                ],
                child: const DashatarShareDialog(),
              ),
            );
          });
        }
      },
      child: ResponsiveLayoutBuilder(
        small: (_, child) => SizedBox(
          key: const Key('dashatar_puzzle_board_small'),
          width: newWidthSmall,
          height: newHeightSmall,
          child: child,
        ),
        medium: (_, child) => SizedBox(
          key: const Key('dashatar_puzzle_board_medium'),
          width: newWidthMedium,
          height: newHeightMedium,
          child: child,
        ),
        large: (_, child) => SizedBox(
          key: const Key('dashatar_puzzle_board_large'),
          width: newWidthLarge,
          height: newHeightLarge,
          child: child,
        ),
        child: (_) => Stack(children: widget.tiles),
      ),
    );
  }
}
