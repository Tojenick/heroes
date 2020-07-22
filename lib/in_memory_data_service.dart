import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'src/hero.dart';
class InMemoryDataService extends MockClient {
  static final _initialHeroes = [
    {'id': 11, 'name': 'Mr. Nice', 'favorite' : false},
    {'id': 12, 'name': 'Narco', 'favorite' : true},
    {'id': 13, 'name': 'Bombasto', 'favorite' : false},
    {'id': 14, 'name': 'Celeritas', 'favorite' : false},
    {'id': 15, 'name': 'Magneta', 'favorite' : true},
    {'id': 16, 'name': 'RubberMan', 'favorite' : false},
    {'id': 17, 'name': 'Dynama', 'favorite' : false},
    {'id': 18, 'name': 'Dr IQ', 'favorite' : false},
    {'id': 19, 'name': 'Magma', 'favorite' : false},
    {'id': 20, 'name': 'Tornado', 'favorite' : false}
  ];
  static List<Hero> _heroesDb;
  static int _nextId;
  static Future<Response> _handler(Request request) async {
    if (_heroesDb == null) resetDb();
    var data;
    switch (request.method) {
      case 'GET':
        final id = int.tryParse(request.url.pathSegments.last);
        if (id != null) {
          data = _heroesDb
              .firstWhere((hero) => hero.id == id); // throws if no match
        } else {
          String prefix = request.url.queryParameters['name'] ?? '';
          final regExp = RegExp(prefix, caseSensitive: false);
          data = _heroesDb.where((hero) => hero.name.contains(regExp)).toList();
        }
        break;
      case 'POST':
        var name = json.decode(request.body)['name'];
        bool favorite = json.decode(request.body)['favorite'];
        var newHero = Hero(_nextId++, name, favorite);
        _heroesDb.add(newHero);
        data = newHero;
        break;
      case 'PUT':
        var heroChanges = Hero.fromJson(json.decode(request.body));
        var targetHero = _heroesDb.firstWhere((h) => h.id == heroChanges.id);
        targetHero.name = heroChanges.name;
        targetHero.favorite = heroChanges.favorite;
        data = targetHero;
        break;
      case 'DELETE':
        var id = int.parse(request.url.pathSegments.last);
        _heroesDb.removeWhere((hero) => hero.id == id);
        // No data, so leave it as null.
        break;
      default:
        throw 'Unimplemented HTTP method ${request.method}';
    }
    return Response(json.encode({'data': data}), 200,
        headers: {'content-type': 'application/json'});
  }
  static resetDb() {
    _heroesDb = _initialHeroes.map((json) => Hero.fromJson(json)).toList();
    _nextId = _heroesDb.map((hero) => hero.id).fold(0, max) + 1;
  }
  static String lookUpName(int id) =>
      _heroesDb.firstWhere((hero) => hero.id == id, orElse: null)?.name;
  InMemoryDataService() : super(_handler);
}