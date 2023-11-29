import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import '../models/place.dart';

Future<sql.Database> _getdatabase() async {
  // Local Database
  final dbPath = await sql.getDatabasesPath();
  final sql.Database db = await sql.openDatabase(
    path.join(dbPath, 'place.db'),
    onCreate: ((db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT) ');
    }),
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final sql.Database db = await _getdatabase();
    final List<Map<String, Object?>> data = await db.query('user_places');
    final List<Place> places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longtitude: row['lng'] as double,
              address: row['address'] as String,
            ),
            title: row['title'] as String,
            image: File(row['image'] as String),
          ),
        )
        .toList();
    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final Directory appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');
    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    ///
    final sql.Database db = await _getdatabase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longtitude,
      'address': newPlace.location.address,
    });
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
