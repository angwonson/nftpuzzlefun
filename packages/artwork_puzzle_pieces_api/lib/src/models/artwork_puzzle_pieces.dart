import 'package:artwork_puzzle_pieces_api/artwork_puzzle_pieces_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

part 'artwork_puzzle_pieces.g.dart';

/// {@template artworkPuzzlePieces}
/// A single artworkPuzzlePieces item.
///
/// Contains a [artworkSplitImages], [artworkSplitImageSizes],
/// [artworkOriginalImageSizes], and [tokenId] and [assetContractAddress]
/// flag.
///
/// If an [tokenId] is provided, it cannot be empty. If no [tokenId] is provided, one
/// will be generated.
///
/// [artworkPuzzlePieces]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class ArtworkPuzzlePieces extends Equatable {
  /// {@macro artworkPuzzlePieces}
  ArtworkPuzzlePieces({
    required this.tokenId,
    required this.assetContractAddress,
    required this.artworkSplitImages,
    required this.artworkSplitImageSizes,
    required this.artworkOriginalImageSizes,
  });

  /// The unique identifier of the artworkPuzzlePieces.
  ///
  /// Cannot be empty.
  final int tokenId;

  /// The assetContractAddress of the artworkPuzzlePieces.
  ///
  /// Note that the artworkPuzzlePieces may NOT be empty.
  final String assetContractAddress;

  /// The description of the artworkPuzzlePieces.
  ///
  /// Defaults to an empty list.
  final List<Image> artworkSplitImages;

  /// Whether the artworkPuzzlePieces is completed.
  ///
  /// Defaults to `false`.
  final List<Tuple2<int, int>> artworkSplitImageSizes;

  /// Whether the artworkPuzzlePieces is completed.
  ///
  /// Defaults to `false`.
  final Tuple2<int, int> artworkOriginalImageSizes;

  /// Returns a copy of this artworkPuzzlePieces with the given values updated.
  ///
  /// {@macro todo}
  ArtworkPuzzlePieces copyWith({
    required int tokenId,
    required String assetContractAddress,
    required List<Image> artworkSplitImages,
    required List<Tuple2<int, int>> artworkSplitImageSizes,
    required Tuple2<int, int> artworkOriginalImageSizes,
  }) {
    return ArtworkPuzzlePieces(
      tokenId: tokenId ?? this.tokenId,
      assetContractAddress: assetContractAddress ?? this.assetContractAddress,
      artworkSplitImages: artworkSplitImages ?? this.artworkSplitImages,
      artworkSplitImageSizes:
          artworkSplitImageSizes ?? this.artworkSplitImageSizes,
      artworkOriginalImageSizes:
          artworkOriginalImageSizes ?? this.artworkOriginalImageSizes,
    );
  }

  /// Deserializes the given [JsonMap] into a [ArtworkPuzzlePieces].
  static ArtworkPuzzlePieces fromJson(JsonMap json) =>
      _$ArtworkPuzzlePiecesFromJson(json);

  /// Converts this [ArtworkPuzzlePieces] into a [JsonMap].
  JsonMap toJson() => _$ArtworkPuzzlePiecesToJson(this);

  @override
  List<Object> get props => [
        tokenId,
        assetContractAddress,
        artworkSplitImages,
        artworkSplitImageSizes,
        artworkOriginalImageSizes
      ];
}
