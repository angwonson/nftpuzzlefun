// ignore_for_file: public_member_api_docs
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:opensea_repository/opensea_repository.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  CollectionsBloc({
    required ArtworkRepository artworkRepository,
  })  : _artworkRepository = artworkRepository,
        super(const CollectionsState()) {
    on<CollectionsSubscriptionRequested>(_onSubscriptionRequested);

    // on<CollectionsEvent>(_onArtworkChanged);
    on<CollectionsChanged>(_onCollectionsChanged);
  }

  final ArtworkRepository _artworkRepository;

  Future<void> _onSubscriptionRequested(
    CollectionsSubscriptionRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    debugPrint('COLLECTION SUBSCRIPTION REQUESTED');
    emit(state.copyWith(status: () => CollectionsStatus.loading));

    // final requestedCollection = event.collectionSlug;

    // a few to try: doodles-official, dartart, themushroompeople,
    // copypasteearth, para-bellum-by-matty-mariansky
    final firebaseRemoteConfig = FirebaseRemoteConfig.instance;
    final collectionsSlugList =
        firebaseRemoteConfig.getString('collections').split(',');
    final collectionList = <String>[];
    for (var i = 0; i < collectionsSlugList.length; i++) {
      collectionList.add(collectionsSlugList[i]);
    }
    // final firstCollection = collectionList[0];

    // const collectionList = [
    //   // 'doodles-official',
    //   'plants-flowers-1',
    //   'textures-patterns-1',
    //   // 'fidenza-by-tyler-hobbs',
    //   // 'dartart',
    //   // 'themushroompeople',
    //   // 'copypasteearth',
    //   // 'empresses',
    //   // 'persona-lamps',
    //   // 'para-bellum-by-matty-mariansky',
    //   // 'genesis-by-dca',
    // ];

    try {
      print('GETING COLLECTIONS SUBSCRIPTION');
      final collections = await _artworkRepository
          .getCollectionsByCollectionList(collectionList);
      debugPrint('COLLECTION RECEIVED $collections');
      // final selectedCollection = collectionList[0];

      emit(
        state.copyWith(
          status: () => CollectionsStatus.success,
          collections: () => collections,
          selectedCollection: () => collectionList[0],
        ),
      );
    } on Exception {
      emit(state.copyWith(status: () => CollectionsStatus.failure));
    }
  }

  void _onCollectionsChanged(
    CollectionsChanged event,
    Emitter<CollectionsState> emit,
  ) {
    print('COLLECTION CHANGED TO: ${event.collectionSlug}');
    emit(state.copyWith(
        selectedCollection: () => event.collectionSlug,
    ),);
  }
}
