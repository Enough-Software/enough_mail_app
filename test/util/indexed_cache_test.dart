import 'package:enough_mail_app/util/indexed_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('add entries', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], 'c');
    expect(cache[3], 'd');
  });

  test('add entries reverse', () {
    final cache = IndexedCache<String>();
    cache[3] = 'd';
    cache[2] = 'c';
    cache[1] = 'b';
    cache[0] = 'a';
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], 'c');
    expect(cache[3], 'd');
  });

  test('insert entries at 0', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.insert(0, 'x');
    expect(cache[1], 'a');
    expect(cache[2], 'b');
    expect(cache[3], 'c');
    expect(cache[4], 'd');
    expect(cache[0], 'x');
    cache.insert(0, 'y');
    expect(cache[2], 'a');
    expect(cache[3], 'b');
    expect(cache[4], 'c');
    expect(cache[5], 'd');
    expect(cache[1], 'x');
    expect(cache[0], 'y');
  });

  test('insert entries at 1', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.insert(1, 'x');
    expect(cache[0], 'a');
    expect(cache[1], 'x');
    expect(cache[2], 'b');
    expect(cache[3], 'c');
    expect(cache[4], 'd');
    cache.insert(1, 'y');
    expect(cache[0], 'a');
    expect(cache[1], 'y');
    expect(cache[2], 'x');
    expect(cache[3], 'b');
    expect(cache[4], 'c');
    expect(cache[5], 'd');
  });

  test('removeAt 2', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.removeAt(2);
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], 'd');
    expect(cache[3], isNull);
    cache.removeAt(2);
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], isNull);
    expect(cache[3], isNull);
  });

  test('removeAt 0', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.removeAt(0);
    expect(cache[0], 'b');
    expect(cache[1], 'c');
    expect(cache[2], 'd');
    expect(cache[3], isNull);
    cache.removeAt(0);
    expect(cache[0], 'c');
    expect(cache[1], 'd');
    expect(cache[2], isNull);
    expect(cache[3], isNull);
  });

  test('removeAt 500', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.removeAt(500);
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], 'c');
    expect(cache[3], 'd');
  });

  test('remove', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.remove('c');
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], 'd');
    expect(cache[3], isNull);
    cache.remove('d');
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], isNull);
    expect(cache[3], isNull);
  });

  test('removeFirstWhere c, d', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.removeFirstWhere((element) => element == 'c');
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], 'd');
    expect(cache[3], isNull);
    cache.removeFirstWhere((element) => element == 'd');
    expect(cache[0], 'a');
    expect(cache[1], 'b');
    expect(cache[2], isNull);
    expect(cache[3], isNull);
  });

  test('removeFirstWhere a, b', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.removeFirstWhere((element) => element == 'a');
    expect(cache[0], 'b');
    expect(cache[1], 'c');
    expect(cache[2], 'd');
    expect(cache[3], isNull);
    cache.removeFirstWhere((element) => element == 'b');
    expect(cache[0], 'c');
    expect(cache[1], 'd');
    expect(cache[2], isNull);
    expect(cache[3], isNull);
  });

  test('clear', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache.clear();
    expect(cache[0], isNull);
    expect(cache[1], isNull);
    expect(cache[2], isNull);
    expect(cache[3], isNull);
  });

  test('getAllCachedEntries', () {
    final cache = IndexedCache<String>();
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    expect(cache.getAllCachedEntries(), ['a', 'b', 'c', 'd']);
  });

  test('shrink cache after adding element', () {
    final cache = IndexedCache<String>(maxCacheSize: 4);
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache[4] = 'e';
    expect(cache.getAllCachedEntries(), ['b', 'c', 'd', 'e']);
    expect(cache[0], isNull);
  });

  test('shrink cache after adding element twice', () {
    final cache = IndexedCache<String>(maxCacheSize: 4);
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache[4] = 'e';
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache[4] = 'e';
    expect(cache.getAllCachedEntries(), ['b', 'c', 'd', 'e']);
    expect(cache[0], isNull);
  });

  test('shrink cache after re-setting first element', () {
    final cache = IndexedCache<String>(maxCacheSize: 4);
    cache[0] = 'a';
    cache[1] = 'b';
    cache[2] = 'c';
    cache[3] = 'd';
    cache[4] = 'e';
    cache[0] = 'a';
    expect(cache.getAllCachedEntries(), ['a', 'c', 'd', 'e']);
    expect(cache[1], isNull);
  });

  test('forEachWhere', () {
    final cache = IndexedCache<_Entry>();
    cache[0] = _Entry('a', 0);
    cache[1] = _Entry('b', 1);
    cache[2] = _Entry('c', 2);
    cache[3] = _Entry('d', 3);
    cache[4] = _Entry('e', 4);
    cache.forEachWhere((e) => e.index >= 3, (e) => e.index++);
    expect(cache[0]?.index, 0);
    expect(cache[1]?.index, 1);
    expect(cache[2]?.index, 2);
    expect(cache[3]?.index, 4);
    expect(cache[4]?.index, 5);
  });
}

class _Entry {
  _Entry(this.text, this.index);

  final String text;
  int index;
}
