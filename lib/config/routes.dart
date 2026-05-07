class Destination {
  const Destination({required this.label, required this.imagePath});

  final String label;
  final String imagePath;
}

const destinations = [
Destination(label: 'Map', imagePath: 'assets/images/tab/map.png'),
Destination(label: 'Recipes', imagePath: 'assets/images/tab/recipes.png'), 
Destination(label: 'Friends', imagePath: 'assets/images/tab/friends.png'),
Destination(label: 'Market', imagePath: 'assets/images/tab/market.png'),
];

class Routes{
  static const home = '/';
  static const levelsMap = '/play';
  static const friends = '/friends';
  static const market = '/market';
  static const bounties = '/bounties';
  static const settings = '/settings';

  static const levelHint = '/play/hint/:level';
  static const levelPlay = '/play/session/:level';
  static const levelWon = '/play/won';
  static const levelFail = '/play/fail/:level';

}