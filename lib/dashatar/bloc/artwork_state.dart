// ignore_for_file: public_member_api_docs

part of 'artwork_bloc.dart';

enum ArtworkStatus { initial, loading, success, failure }

class ArtworkState extends Equatable {
  const ArtworkState({
    this.status = ArtworkStatus.initial,
    this.artworks = const [],
    this.artworkSplitImages = const [],
    this.artworkSplitImageSizes = const [],
    this.artworkOriginalImageSizes = const [],
    this.artwork = 0,
    this.selectedArtwork,
  });

  final ArtworkStatus status;

  /// The list of all available [Artwork]s.
  final List<Artwork> artworks;
  final List<List<Image>> artworkSplitImages;
  final List<List<Tuple2<int, int>>> artworkSplitImageSizes;
  final List<Tuple2<int, int>> artworkOriginalImageSizes;

  /// Currently selected [Artwork].
  final int artwork;
  final Artwork? selectedArtwork;

  @override
  List<Object> get props => [status, artworks, artworkSplitImages, artworkSplitImageSizes, artworkOriginalImageSizes, artwork];

  ArtworkState copyWith({
    ArtworkStatus Function()? status,
    List<Artwork> Function()? artworks,
    List<List<Image>> Function()? artworkSplitImages,
    List<List<Tuple2<int, int>>> Function()? artworkSplitImageSizes,
    List<Tuple2<int, int>> Function()? artworkOriginalImageSizes,
    int Function()? artwork,
    Artwork Function()? selectedArtwork,
  }) {
    return ArtworkState(
      status: status != null ? status() : this.status,
      artworks: artworks != null ? artworks() : this.artworks,
      artworkSplitImages: artworkSplitImages != null
          ? artworkSplitImages()
          : this.artworkSplitImages,
      artworkSplitImageSizes: artworkSplitImageSizes != null
          ? artworkSplitImageSizes()
          : this.artworkSplitImageSizes,
      artworkOriginalImageSizes: artworkOriginalImageSizes != null
          ? artworkOriginalImageSizes()
          : this.artworkOriginalImageSizes,
      artwork: artwork != null ? artwork() : this.artwork,
      selectedArtwork: selectedArtwork != null ? selectedArtwork() : this.selectedArtwork,
    );
  }
}
