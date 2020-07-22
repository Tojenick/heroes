class Hero {
  final int id;
  String name;
  bool favorite;
  Hero(this.id, this.name,this.favorite);
  factory Hero.fromJson(Map<String, dynamic> hero) =>
      Hero(_toInt(hero['id']), hero['name'], hero['favorite']);
  Map toJson() => {'id': id, 'name': name, 'favorite': favorite};
}
int _toInt(id) => id is int ? id : int.parse(id);