import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movies_app/models/Movie.dart';

List<movie> moviesList = [];

Future fetchMovie({required String URL, required String auth}) async {
  final response =
      await http.get(Uri.parse(URL), headers: {'Authorization': auth});

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['movies'];
  } else {
    throw Exception('Failed to connect to database.');
  }
}

// FIX 1: Return typed Future<List<movie>> so callers get proper type safety.
Future<List<movie>> retrieveMoviesList() async {
  // FIX 2: Clear before filling — prevents infinite duplicate growth
  //        on every widget rebuild / repeated FutureBuilder call.
  moviesList.clear();

  var fetchedMovies = await fetchMovie(
      URL: "https://wookie.codesubmit.io/movies",
      auth: "Bearer Wookie2021");

  var movies = List<Map<String, dynamic>>.from(fetchedMovies);

  for (var _movie in movies) {
    moviesList.add(movie(
        title: _movie["title"],
        released_on: _movie["released_on"],
        overview: _movie["overview"],
        imdb_rating: _movie["imdb_rating"],
        genres: _movie["genres"],
        // FIX 3: poster and backdrop were swapped — corrected.
        poster:   _movie["poster"],
        backdrop: _movie["backdrop"],
        length: _movie["length"],
        id: _movie["id"],
        isFavorite: false));
  }

  return moviesList;
}