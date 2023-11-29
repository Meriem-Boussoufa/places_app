import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  final double latitude;
  final double longtitude;
  final String address;

  const PlaceLocation(
      {required this.latitude,
      required this.longtitude,
      required this.address});
}

class Place {
  final String id;
  final String title;
  final File image;
  final PlaceLocation location;

  Place({
    // Added cause of creating table of database
    String? id,
    required this.location,
    required this.title,
    required this.image,
  }) : id = id ?? uuid.v4();
}
