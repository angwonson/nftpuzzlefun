// import 'dart:ui';
// ignore_for_file: flutter_style_todos

import 'dart:async';

import 'package:artwork_puzzle_pieces_repository/artwork_puzzle_pieces_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:nftpuzzlefun/dashatar/artworks/my_custom_artwork_one.dart';
// import 'package:nftpuzzlefun/helpers/squaresplitter.dart';
import 'package:opensea_repository/opensea_repository.dart';
import 'package:tuple/tuple.dart';

part 'artwork_event.dart';
part 'artwork_state.dart';

/// doc
class ArtworkBloc extends Bloc<ArtworkEvent, ArtworkState> {
  /// doc
  ArtworkBloc({
    required ArtworkRepository artworkRepository,
    required ArtworkPuzzlePiecesRepository artworkPuzzlePiecesRepository,
  })  : _artworkRepository = artworkRepository,
        _artworkPuzzlePiecesRepository = artworkPuzzlePiecesRepository,
        super(const ArtworkState()) {
    on<ArtworkSubscriptionRequested>(_onSubscriptionRequested);

    // on<ArtworkEvent>(_onArtworkChanged);
    on<ArtworkChanged>(_onArtworkChanged);
    // on<ArtworkCollectionChanged>(_onArtworkCollectionChanged);
  }

  final ArtworkRepository _artworkRepository;
  final ArtworkPuzzlePiecesRepository _artworkPuzzlePiecesRepository;

  Future<void> _onSubscriptionRequested(
    ArtworkSubscriptionRequested event,
    Emitter<ArtworkState> emit,
  ) async {
    emit(state.copyWith(status: () => ArtworkStatus.loading));

    final collection = event.collectionSlug;
    debugPrint('ARTWORK SUBSCRIPTION REQUESTED $collection');

    try {
      final artworks =
          await _artworkRepository.getArtworksByCollection(collection);
      debugPrint('COLLECTION RECEIVED');

      /// Process images
      // First get images and image sizes from firebase/cloud storage
      // if image data doesn't exist in firebase, use the squaresplitter
      // also emit new state -> processing images and set up progressindicator
      final artworkOriginalImageUrls = List<String>.empty(growable: true);
      final artworkSplitImages = List<List<String>>.empty(growable: true);
      final artworkSplitImageSizes =
          List<List<Tuple2<int, int>>>.empty(growable: true);
      final artworkOriginalImageSizes =
          List<Tuple2<int, int>>.empty(growable: true);

      // get split images from firebase storage. if not exists, then generate
      // existsInStorage actually isn't being used yet
      const existsInStorage = false;
      if (!existsInStorage) {
        // run squaresplitter and shove data into firebase
        for (final artwork in artworks) {
          // TODO: this call is working and we can start replacing the old code (mySplitImagesTuple) with this (puzzlePiecesTuples) result
          final puzzlePiecesTuples = await _artworkPuzzlePiecesRepository.getPuzzlePieces(
            openseaAssetId: artwork.id,
            inputImage: artwork.imageUrl,
            horizontalPieceCount: 4,
            verticalPieceCount: 4,
          );

          // artworkSplitImages[aIndex]
          // final mySplitImagesTuple = await splitImage(
          //   inputImage: artwork.imageUrl,
          //   horizontalPieceCount: 4,
          //   verticalPieceCount: 4,
          // );
          artworkOriginalImageUrls.add(puzzlePiecesTuples.item4);
          artworkSplitImages.add(puzzlePiecesTuples.item1);
          artworkSplitImageSizes.add(puzzlePiecesTuples.item2);
          artworkOriginalImageSizes.add(puzzlePiecesTuples.item3);
          // debugPrint(artwork.imageUrl);

          // TODO: insert into firestore, upload to cloud storage

        }
      } else {
        // populate from storage result
      }

      emit(
        state.copyWith(
          status: () => ArtworkStatus.success,
          artworks: () => artworks,
          artworkOriginalImageUrls: () => artworkOriginalImageUrls,
          artworkSplitImages: () => artworkSplitImages,
          artworkSplitImageSizes: () => artworkSplitImageSizes,
          artworkOriginalImageSizes: () => artworkOriginalImageSizes,
          selectedArtwork: () => artworks[0],
        ),
      );
    } on Exception {
      emit(state.copyWith(status: () => ArtworkStatus.failure));
    }
  }

  // var artworks = await
  //     _artworkRepository.getArtworksByCollection(collection);
  // await emit.forEach<List<Artwork>>(
  //   _artworkRepository.getArtworksByCollection(collection),
  //   onData: (artworks) => state.copyWith(
  //     status: () => ArtworkStatus.success,
  //     artworks: () => artworks,
  //   ),
  //   onError: (_, __) => state.copyWith(
  //     status: () => ArtworkStatus.failure,
  //   ),
  // );
  // }

  void _onArtworkChanged(
    ArtworkChanged event,
    Emitter<ArtworkState> emit,
  ) {
    final mySelectedArtwork = state.artworks[event.artworkIndex];
    // print('ARTWORK INDEX CHANGED TO: ${event.artworkIndex}');
    emit(state.copyWith(
      artwork: () => event.artworkIndex,
      selectedArtwork: () => mySelectedArtwork,
    ),);
  }

  // Future<void> fetchArtworksByCollection(String? collection) async {
  //   if (collection == null || collection.isEmpty) return;
  //
  //   // emit(state.copyWith(status: ArtworkStatus.loading));
  //
  //   try {
  //     final artworks = Artwork.fromRepository(
  //       await _weatherRepository.getWeather(collection),
  //     );
  //     final units = state.temperatureUnits;
  //     final value = units.isFahrenheit
  //         ? weather.temperature.value.toFahrenheit()
  //         : weather.temperature.value;
  //
  //     // emit(
  //     //   state.copyWith(
  //     //     status: WeatherStatus.success,
  //     //     temperatureUnits: units,
  //     //     weather: weather.copyWith(temperature: Temperature(value: value)),
  //     //   ),
  //     // );
  //   } on Exception {
  //     emit(state.copyWith(status: WeatherStatus.failure));
  //   }
  // }

  // Future<void> refreshWeather() async {
  //   if (!state.status.isSuccess) return;
  //   if (state.weather == Weather.empty) return;
  //   try {
  //     final weather = Weather.fromRepository(
  //       await _weatherRepository.getWeather(state.weather.collection),
  //     );
  //     final units = state.temperatureUnits;
  //     final value = units.isFahrenheit
  //         ? weather.temperature.value.toFahrenheit()
  //         : weather.temperature.value;
  //
  //     emit(
  //       state.copyWith(
  //         status: WeatherStatus.success,
  //         temperatureUnits: units,
  //         weather: weather.copyWith(temperature: Temperature(value: value)),
  //       ),
  //     );
  //   } on Exception {
  //     emit(state);
  //   }
  // }
}
