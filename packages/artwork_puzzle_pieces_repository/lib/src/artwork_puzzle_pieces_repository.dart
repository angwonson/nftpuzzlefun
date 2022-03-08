// ignore_for_file: flutter_style_todos, avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:squaresplitter/squaresplitter.dart';
import 'package:tuple/tuple.dart';

/// {@template artwork_puzzle_pieces_repository}
/// A repository that handles artwork split images related requests.
/// {@endtemplate}
class ArtworkPuzzlePiecesRepository {
  /// {@macro artwork_puzzle_pieces_repository}
  const ArtworkPuzzlePiecesRepository();

  /// Given required params, look up images in firebase storage or generate with
  /// squaresplitter, save images to local storage andrespond with correct data
  /// structure
  // Future<Tuple3<List<String>, List<Tuple2<int, int>>, Tuple2<int, int>>> getPuzzlePieces(
  // Might want to replace the above line with some actual models
  Future<Tuple4<List<String>, List<Tuple2<int, int>>, Tuple2<int, int>, String>>
      getPuzzlePieces({
    required int openseaAssetId,
    required String inputImage,
    required int horizontalPieceCount,
    required int verticalPieceCount,
  }) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final CollectionReference openseaAssetsCollection =
        firestoreInstance.collection('puzzle_pieces');

    // get the meta data from firestore (if it exists)
    final firebasePuzzlePiecesMetaData =
        await openseaAssetsCollection.doc(openseaAssetId.toString()).get();

    // exists unless one of the try statements fails below
    var ogImageExists = true;

    // check if record exists
    if (!firebasePuzzlePiecesMetaData.exists) {
      ogImageExists = false;
    }

    // check storage, it image doesn't exist run squaresplitter and insert to storage
    final storage = firebase_storage.FirebaseStorage.instance;

    // get ref to FirebaseStorage storage object so we can see if it exists and has the correct metadata
    final ogRef = storage.ref('puzzle_pieces/$openseaAssetId/original.png');

    /*
    // get metadata if file exists
    try {
      final metadata = await ogRef.getMetadata();
      // print('METADATA FOR OG IMAGE ${metadata.customMetadata!['width']}.');
    } on FirebaseException catch (e) {
      // print("Original image doesn't exist in firebase storage yet metadata");
      ogImageExists = false;
    }


    try {
      final downloadURL = await ogRef.getDownloadURL();
      // print('downloadURL FOR OG IMAGE $downloadURL.');
    } on FirebaseException catch (e) {
      // print("Original image doesn't exist in firebase storage yet downloadURL");
      ogImageExists = false;
    }
    */

    // if image hasn't been cached yet, cache it in storage, with meta data and return OGImage model object with width and height meta data
    if (!ogImageExists) {
      // step 1 run splitimage as all meta data including for the original uncut image comes from this utility
      // print('BUILDING SPLITIMAGES NEW STYLE');
      final mySplitImagesTuple = await splitPuzzleImage(
        inputImage: inputImage,
        horizontalPieceCount: horizontalPieceCount,
        verticalPieceCount: verticalPieceCount,
      );

      // step 2 (THIS SHOULD GO LAST AFTER THE PUZZLE PIECES - fake lock mechanism to prevent people from trying to use this image before all the puzzle pieces are ready): upload ogImage to firebase storage
      final ogImageMetadata = firebase_storage.SettableMetadata(
        cacheControl: 'max-age=60',
        customMetadata: <String, String>{
          'width': mySplitImagesTuple.item3.item1.toString(),
          'height': mySplitImagesTuple.item3.item2.toString(),
        },
      );

      // put this ogImage into the firebase storage location
      // TODO: put this into firestore db as well, make sure to include download url though
      await ogRef.putData(mySplitImagesTuple.item4, ogImageMetadata);
      // get download url
      final ogDownloadURL = await ogRef.getDownloadURL();
      // print('ogDownloadURL being set: $ogDownloadURL');

      // step2 re-download it to local storage and set the return variable/model object

      // step3 return OGImage object with local storage path, width and height all as strings

      // step 1 checkfirebase storage to see if existing images and meta data exist, if so return that

      // step 2 images aren't split/cached yet so run squaresplitter and upload ther results to firebase storage, then return as nowmal
      // artworkSplitImages[aIndex]

      // final artworkSplitImages = List<List<String>>.empty(growable: true);
      // final artworkSplitImageSizes =
      // List<List<Tuple2<int, int>>>.empty(growable: true);
      // final artworkOriginalImageSizes =
      // List<Tuple2<int, int>>.empty(growable: true);

      // loop through mySplitImagesTuple.item1 and upload them to firebase
      var counter = 0;
      // var storageRef =
      //     firebase_storage.FirebaseStorage.instance;
      // final puzzlePiecesList = Map()List<List<String>>.empty(growable: true);
      final puzzlePiecesList = List<Map<String, dynamic>>.empty(growable: true);

      for (final splitImage in mySplitImagesTuple.item1) {
        // some things we already know before we upload to storage, like sizes
        // artworkSplitImageSizes.add(mySplitImagesTuple.item2[counter].item2);
        // artworkOriginalImageSizes.add(mySplitImagesTuple.item3);

        // print('SPLIT IMAGE NEW: $splitImage');

        // Create your custom metadata.
        final metadata = firebase_storage.SettableMetadata(
          cacheControl: 'max-age=60',
          customMetadata: <String, String>{
            'width': mySplitImagesTuple.item2[counter].item1.toString(),
            'height': mySplitImagesTuple.item2[counter].item2.toString(),
            // 'originalwidth': mySplitImagesTuple.item3.item1.toString(),
            // 'originalheight': mySplitImagesTuple.item3.item2.toString(),
          },
        );

        final puzzlepieceRef =
            storage.ref('puzzle_pieces/$openseaAssetId/$counter.png');
        // ref =
        // firebase_storage.FirebaseStorage.instance.ref().child('puzzle_pieces/$openseaAssetId/$counter.png');
        // await firebase_storage.FirebaseStorage.instance.ref();

        // try {
        // Upload raw data.

        // this works! just disabled temporarily to speed up testing
        // TODO: put this into firestore db as well, make sure to include download url though
        await puzzlepieceRef.putData(splitImage, metadata);

        // get download url
        final puzzlepieceDownloadURL = await puzzlepieceRef.getDownloadURL();
        // print('puzzlepieceDownloadURL being set: $puzzlepieceDownloadURL');

        // var identifier = Map();
        // identifier['width'] = mySplitImagesTuple.item2[counter].item1;
        puzzlePiecesList.add(<String, dynamic>{
          'width': mySplitImagesTuple.item2[counter].item1,
          'height': mySplitImagesTuple.item2[counter].item2,
          'download_url': puzzlepieceDownloadURL
        });

        // final fakePuzzlePieceMOdeled =

        // set up insert record with downloadurl, width and height
        //insert to firestore
        // TODO: fix this to create a specific collection for each puzzle complexity (4x4, 3x2, etc)
        // await openseaAssetsCollection
        //     .add({
        //   'opensea_asset_id': openseaAssetId,
        //   'puzzle_piece_download_url': puzzlepieceDownloadURL,
        //   'width': width,
        //   'height': height
        // })
        //     .then((value) => print('OGIMAGE Added to Firestore'))
        //     .catchError((error) => print('Failed to add ogDownloadURL: $error'));

        // Get raw data.
        // final Uint8List downloadedData = await ref.getData();
        // prints -> Hello World!
        // print(utf8.decode(downloadedData));
        // } on firebase_core.FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
        // }

        // return meta data to the caller
        counter++;
      }

      // artworkSplitImages.add(mySplitImagesTuple.item1);
      // artworkSplitImageSizes.add(mySplitImagesTuple.item2);
      // artworkOriginalImageSizes.add(mySplitImagesTuple.item3);

      // set up insert record with downloadurl, width and height
      //insert to firestore
      await openseaAssetsCollection.doc(openseaAssetId.toString()).set({
        // 'opensea_asset_id': openseaAssetId.toString(),
        'og_download_url': ogDownloadURL,
        'width': mySplitImagesTuple.item3.item1,
        'height': mySplitImagesTuple.item3.item2,
        'puzzle_pieces': puzzlePiecesList
        // 'puzzle_pieces': [
        //   {'width': 123, 'height': 143, 'download_url': 'testurl'},
        //   {'width': 125, 'height': 144, 'download_url': 'testurl2'}
        // ]
      });
      // .then((value) => print('OGIMAGE Added to Firestore'));
      // .catchError((String error) => print('Failed to add ogDownloadURL: $error'));

      // } else {
    }
    // end if ogImageExists

    // image exists, so lets try and load it all from firebase storage
    // Step 1) get original image downloadurl and meta and copy to local storage
    // NOTE: local storage is eluding me. let's move on and just use the url and Image.network()

    // final firebasePuzzlePiecesMetaData =
    //     await openseaAssetsCollection.doc(openseaAssetId.toString()).get();
    // print('DOCUMENT SNAPSHOT: ${firebasePuzzlePiecesMetaData.data()}');
    // final data = firebasePuzzlePiecesMetaData.data() as Map<String, dynamic>;
    // print('DOCUMENT SNAPSHOT ID: ${firebasePuzzlePiecesMetaData.id}');
    // print(
    //     'DOCUMENT SNAPSHOT OGDOWNLOADURL: ${firebasePuzzlePiecesMetaData.get('og_download_url')}');

    // final ogMetadata = await ogRef.getMetadata();
    final ogDownloadURL =
        firebasePuzzlePiecesMetaData.get('og_download_url').toString();
    final ogWidth =
        int.parse(firebasePuzzlePiecesMetaData.get('width').toString());
    final ogHeight =
        int.parse(firebasePuzzlePiecesMetaData.get('height').toString());
    // print('URRRG DOWNLOAD URL $ogDownloadURL');
    // final ogDownloadURL = await ogRef.getDownloadURL(); // do we need this since we are going to use local storage as another cache layer?
    // here I present you with some null safety nonsense
    // final ogWidth = ogMetadata.customMetadata == null
    //     ? 0
    //     : int.parse(ogMetadata.customMetadata!['width'].toString());
    // final ogHeight = ogMetadata.customMetadata == null
    //     ? 0
    //     : int.parse(ogMetadata.customMetadata!['height'].toString());
    final artworkOriginalImageSize = Tuple2<int, int>(ogWidth, ogHeight);
    // print('OG IMAGE HEIGHT POST $ogHeight');

    // final appDocDir = await getApplicationDocumentsDirectory();
    // final downloadToFile = File('${appDocDir.path}/puzzle_pieces/$openseaAssetId/original.png');
    // print('downloadToFile ${appDocDir.path}');
    // await firebase_storage.FirebaseStorage.instance
    //     .ref('puzzle_pieces/$openseaAssetId/original.png')
    //     .writeToFile(downloadToFile);
    // print("OK/NOTOK");
    // // TODO: test artworkOriginalImageLocalPath to make sure it is working
    // final artworkOriginalImageLocalPath = '${appDocDir.path}puzzle_pieces/$openseaAssetId/original.png';

    // Step 2) get puzzle pieces downloadurl, meta, and copy to local storage

    final artworkSplitImages = List<String>.empty(growable: true);
    final artworkSplitImageSizes = List<Tuple2<int, int>>.empty(growable: true);

    firebasePuzzlePiecesMetaData['puzzle_pieces'].forEach((dynamic item) {
      // print('ITEM DLURL: ${item['download_url']}');

      final pieceDownloadURL = item['download_url'] as String;
      final pieceWidth = item['width'] as int;
      final pieceHeight = item['height'] as int;

      final artworkPuzzlePieceImageSize =
          Tuple2<int, int>(pieceWidth, pieceHeight);

      artworkSplitImageSizes.add(artworkPuzzlePieceImageSize);
      artworkSplitImages.add(pieceDownloadURL);
    });

    /*
    for (var i = 0; i <= 15; i++) {
      final puzzlepieceRef =
          storage.ref('puzzle_pieces/$openseaAssetId/$i.png');

      final pieceDownloadURL = await puzzlepieceRef.getDownloadURL();
      final pieceMetadata = await ogRef.getMetadata();

      final pieceWidth = pieceMetadata.customMetadata == null
          ? 0
          : int.parse(pieceMetadata.customMetadata!['width'].toString());
      final pieceHeight = pieceMetadata.customMetadata == null
          ? 0
          : int.parse(pieceMetadata.customMetadata!['height'].toString());
      final artworkPuzzlePieceImageSize =
          Tuple2<int, int>(pieceWidth, pieceHeight);

      artworkSplitImageSizes.add(artworkPuzzlePieceImageSize);
      artworkSplitImages.add(pieceDownloadURL);
    }
*/

    // return false;
    // probably want to return the device local version of the main artwork as well:
    // use firebase_storage.writeToFile to copy image to local device and only return the path as String
    final myTuple =
        Tuple4<List<String>, List<Tuple2<int, int>>, Tuple2<int, int>, String>(
            artworkSplitImages,
            artworkSplitImageSizes,
            artworkOriginalImageSize,
            ogDownloadURL,);
    // print('FINISHED BUILDING PUZZLE PIECES DATA FOR ONE IMAGE');
    return myTuple;
  }
}
