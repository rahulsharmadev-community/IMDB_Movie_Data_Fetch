import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'movie.dart';

class Omdb {
  final String title_url = "http://www.omdbapi.com/?t=";
  final String imdbid_url = "http://www.omdbapi.com/?i=";
  final String _api;
  final String _movieId;

  // Movie movie;
  // Movie get data => movie;
  Omdb(this._api, this._movieId);

  Future<Movie> getMovie() async {
    String _titleurl = "$title_url$_movieId&apikey=$_api";
    String _imdbidurl = "$imdbid_url$_movieId&apikey=$_api";
    var decodedjson;
    var res = await http.get(Uri.parse(
        _movieId.substring(0, 2).contains("tt") ? _imdbidurl : _titleurl));

    decodedjson = jsonDecode(res.body);
    return Movie.fromJson(decodedjson);
  }
}
