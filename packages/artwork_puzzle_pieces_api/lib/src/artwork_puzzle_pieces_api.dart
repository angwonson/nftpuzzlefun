import 'package:artwork_puzzle_pieces_api/artwork_puzzle_pieces_api.dart';
/// {@template artwork_puzzle_pieces_api}
/// The interface and models for an API providing access to artwork puzzle pieces.
/// {@endtemplate}
abstract class ArtworkPuzzlePiecesApi {
  /// {@macro artwork_puzzle_pieces_api}
  const ArtworkPuzzlePiecesApi();

  /// Provides a [Stream] of all todos.
  Stream<List<ArtworkPuzzlePieces>> getArtworkPuzzlePieces();

  /// Saves a [artworkPuzzlePieces].
  ///
  /// If a [artworkPuzzlePieces] with the same id already exists, it will be replaced.
  Future<void> saveArtworkPuzzlePieces(ArtworkPuzzlePieces artworkPuzzlePieces);

}


/// Error thrown when a [ArtworkPuzzlePieces] with a given id is not found.
class ArtworkPuzzlePiecesNotFoundException implements Exception {}
