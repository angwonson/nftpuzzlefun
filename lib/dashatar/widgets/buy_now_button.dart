import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:nftpuzzlefun/audio_control/audio_control.dart';
import 'package:nftpuzzlefun/dashatar/dashatar.dart';
import 'package:nftpuzzlefun/helpers/helpers.dart';
import 'package:nftpuzzlefun/l10n/l10n.dart';
// import 'package:nftpuzzlefun/puzzle/puzzle.dart';
import 'package:nftpuzzlefun/theme/theme.dart';
// import 'package:nftpuzzlefun/timer/timer.dart';

/// {@template dashatar_puzzle_action_button}
/// Displays the action button to start or shuffle the puzzle
/// based on the current puzzle state.
/// {@endtemplate}
class BuyNowButton extends StatefulWidget {
  /// {@macro dashatar_puzzle_action_button}
  const BuyNowButton({Key? key}) : super(key: key);

  @override
  State<BuyNowButton> createState() => _BuyNowButtonState();
}

class _BuyNowButtonState extends State<BuyNowButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((DashatarThemeBloc bloc) => bloc.state.theme);
    final selectedArtwork =
        context.select((ArtworkBloc bloc) => bloc.state.selectedArtwork);

    final status =
        context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final isLoading = status == DashatarPuzzleStatus.loading;

    final text = Platform.isIOS || Platform.isMacOS
        ? context.l10n.buyNowApple
        : context.l10n.buyNow;

    // hack to try and get apple store approval - remove button for now
    if (Platform.isIOS || Platform.isMacOS) {
      return Container();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Tooltip(
        key: ValueKey(status),
        message: context.l10n.buyNowTooltip,
        verticalOffset: 40,
        child: PuzzleButton(
          onPressed: isLoading
              ? null
              : Platform.isIOS || Platform.isMacOS
                  ? () {
                      debugPrint(
                          'clicked on an apple platform (copy to clipboard versus openLink)');
                      final affLink =
                          '${selectedArtwork?.permalink}?ref=0x9c6f4531928eb78d0f758702cbd82672f9c3e670';
                      // openLink(affLink);
                      // Clipboard.setData(ClipboardData(text: affLink));
                      // TODO: show some indicator to the user that the text was copied
                      Clipboard.setData(ClipboardData(text: affLink)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Permalink copied to clipboard")));
                      });
                    }
                  : () {
                      debugPrint('clicked');
                      final affLink =
                          '${selectedArtwork?.permalink}?ref=0x9c6f4531928eb78d0f758702cbd82672f9c3e670';
                      openLink(affLink);
                    },
          textColor: isLoading ? theme.defaultColor : null,
          child: Text(
            text,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
