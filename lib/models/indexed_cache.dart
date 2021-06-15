import 'package:collection/collection.dart' show IterableExtension;

class IndexedCache<T> {
  static const int defaultMaxSize = 1000;
  final List<_CacheElement<T?>> _elements = <_CacheElement<T>>[];
  final int maxSize;
  int _currentAddIndex = 0;

  IndexedCache({this.maxSize = defaultMaxSize});

  _CacheElement? _cacheElementAt(int index) {
    return _elements.firstWhereOrNull((element) => element.index == index);
  }

  T? elementAt(int index) {
    final cacheElement = _cacheElementAt(index);
    return cacheElement?.element;
  }

  int add(T element) {
    final index = _currentAddIndex;
    _elements.add(_CacheElement(index, element));
    _currentAddIndex++;
    if (_elements.length > maxSize) {
      _elements.removeAt(0);
    }
    return index;
  }

  void replace(int index, T element) {
    final cacheElement = _cacheElementAt(index);
    if (cacheElement != null) {
      cacheElement.element = element;
    } else {
      _elements.add(_CacheElement(index, element));
    }
  }

  int? remove(T element) {
    final cacheElement =
        _elements.firstWhereOrNull((ce) => ce.element == element);
    if (_remove(cacheElement)) {
      return cacheElement!.index;
    } else {
      return null;
    }
  }

  T? removeAt(int index) {
    final element = _cacheElementAt(index);
    _remove(element);
    return element?.element;
  }

  bool _remove(_CacheElement? toBeRemoved) {
    if (toBeRemoved == null) {
      return false;
    }
    _currentAddIndex--;
    final isRemoved = _elements.remove(toBeRemoved);
    for (final element in _elements) {
      if (element.index > toBeRemoved.index) {
        element.index--;
      }
    }
    return isRemoved;
  }
}

class _CacheElement<T> {
  int index;
  T element;
  _CacheElement(this.index, this.element);
}
