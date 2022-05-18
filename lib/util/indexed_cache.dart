import 'package:collection/collection.dart';

/// Temporarily stores values that can be accessed by an integer index.
class IndexedCache<T> {
  /// default maximum cache size is 200
  static const int defaultMaxCacheSize = 200;

  /// Creates a new cache
  IndexedCache({this.maxCacheSize = defaultMaxCacheSize});

  /// The maximum size of the cache
  final int maxCacheSize;

  final _entries = <T?>[];
  final _indices = <int>[];

  /// Inserts the [value] at the [index] and changes
  /// the source indices of subsequent entries
  void insert(int index, T value) {
    while (_entries.length <= index) {
      _entries.add(null);
    }
    _entries.insert(index, value);
    _indices.add(index);
    if (_indices.length > maxCacheSize) {
      _shrink();
    }
  }

  void _shrink() {
    final removeIndex = _indices.removeAt(0);
    _entries[removeIndex] = null;
  }

  /// Deletes the entry at the given [index]
  T? removeAt(int index) {
    if (index > _entries.length) {
      return null;
    }
    final removed = _entries.removeAt(index);
    if (removed != null) {
      _indices.remove(index);
    }
    return removed;
  }

  /// Deletes the entry with the [value]
  bool remove(T value) {
    final index = _entries.indexOf(value);
    if (index == -1) {
      return false;
    }
    removeAt(index);
    return true;
  }

  /// Deletes the entry that matches the given [matcher] function.
  T? removeFirstWhere(bool Function(T element) matcher) {
    final index =
        _entries.indexWhere((value) => value != null && matcher(value));
    if (index == -1) {
      return null;
    }
    return removeAt(index);
  }

  /// Clears all entries from this cache.
  void clear() {
    _entries.clear();
    _indices.clear();
  }

  /// Retrieves the value for the given [index].
  T? operator [](int index) => index < _entries.length ? _entries[index] : null;

  /// Set the value for the given [index].
  operator []=(int index, T value) {
    if (_entries.length > index) {
      final existing = _entries[index];
      _entries[index] = value;
      if (existing != null) {
        return;
      }
    } else {
      while (_entries.length < index) {
        _entries.add(null);
      }
      _entries.add(value);
    }
    _indices.add(index);
    if (_indices.length > maxCacheSize) {
      _shrink();
    }
  }

  /// Retrieves the first matching element or null when no entry matches
  T? firstWhereOrNull(bool Function(T element) test) =>
      _entries.firstWhereOrNull((value) => value != null && test(value));

  /// Retrieves all cached entries
  List<T> getAllCachedEntries() =>
      List<T>.from(_entries.where((value) => value != null));

  /// Triggers the [action] for any elements that fit the [test]
  void forEachWhere(
      bool Function(T element) test, void Function(T element) action) {
    _entries
        .where((value) => value != null && test(value))
        .forEach((element) => action(element as T));
  }
}
