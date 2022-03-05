import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imglib;
import 'package:tuple/tuple.dart';

/// {@template squaresplitter}
/// A utility package to split images in a grid pattern
/// {@endtemplate}
// class Squaresplitter {
//   /// {@macro squaresplitter}
//   const Squaresplitter();

  /// split an image in a grid pattern
  Future<
          Tuple4<List<Uint8List>, List<Tuple2<int, int>>, Tuple2<int, int>, Uint8List>>
      splitPuzzleImage(
          {required String inputImage,
          required int horizontalPieceCount,
          required int verticalPieceCount,}) async {
    final rawImg = (await http.get(Uri.parse(inputImage))).bodyBytes;
    final baseSizeImage = imglib.decodeImage(rawImg);

    final originalWidth = baseSizeImage!.width;
    final originalHeight = baseSizeImage.height;
    final xLength = (baseSizeImage.width / horizontalPieceCount).floor();
    final yLength = (baseSizeImage.height / verticalPieceCount).floor();
    final xRemainder = baseSizeImage.width.remainder(horizontalPieceCount);
    final yRemainder = baseSizeImage.height.remainder(verticalPieceCount);
    print(
      'X $xLength BY Y: $yLength REMAINDER X: $xRemainder Y: $yRemainder',
    );
    final pieceList = <imglib.Image>[];

    var startX = 0;
    var startY = 0;
    final outputImageSizeList = <Tuple2<int, int>>[];
    for (var y = 0; y < verticalPieceCount; y++) {
      /// Add an extra pixel if there is a remainder from the division above
      var tweakedYLength = yLength;
      if (y < yRemainder) {
        tweakedYLength++;
      }
      for (var x = 0; x < horizontalPieceCount; x++) {
        var tweakedXLength = xLength;
        if (x < xRemainder) {
          tweakedXLength++;
        }
        print(
            'YCOUNT: $y XCOUNT: $x START X: $startX START Y: $startY END X: $tweakedXLength END Y: $tweakedYLength',);
        outputImageSizeList
            .add(Tuple2<int, int>(tweakedXLength, tweakedYLength));
        pieceList.add(
          imglib.copyCrop(
              baseSizeImage, startX, startY, tweakedXLength, tweakedYLength,),
        );
        startX = startX + tweakedXLength;
      }
      startX = 0;
      startY = startY + tweakedYLength;
    }

    /// Convert image from image package to Image Widget to display
    final outputImageList = <Uint8List>[];
    for (final img in pieceList) {
      outputImageList.add(Uint8List.fromList(imglib.encodeJpg(img)));
      // .add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }

    final myTuple =
        Tuple4<List<Uint8List>, List<Tuple2<int, int>>, Tuple2<int, int>, Uint8List>(
      outputImageList,
      outputImageSizeList,
      Tuple2<int, int>(originalWidth, originalHeight),
          rawImg,
    );
    return myTuple;
  }
// }
