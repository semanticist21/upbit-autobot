import 'dart:collection';

class MyCustomList<T> with ListMixin<T> {
  MyCustomList(this.l);
  final List<T> l;
  late List<void Function()> addListeners = List.empty(growable: true);
  late List<void Function()> changeListeners = List.empty(growable: true);
  late List<void Function(int)> removeListener = List.empty(growable: true);
  late List<void Function()> cleanListeners = List.empty(growable: true);

  @override
  set length(int newLength) {
    l.length = newLength;
  }

  @override
  int get length => l.length;
  @override
  T operator [](int index) => l[index];
  @override
  void operator []=(int index, dynamic value) {
    l[index] = value;
    notifyListeners(changeListeners);
  }

  @override
  void add(T element) {
    l.add(element);
    notifyListeners(addListeners);
  }

  @override
  T removeAt(int index) {
    notifyRemoveListeners(index);
    return super.removeAt(index);
  }

  @override
  void clear() {
    super.clear();
    notifyListeners(cleanListeners);
  }

  @override
  void addAll(Iterable<T> iterable) {
    for (var element in iterable) {
      l.add(element);
    }
  }

  void addInsertListener(void Function() function) =>
      addListeners.add(function);
  void addRemoveListener(void Function(int) function) =>
      removeListener.add(function);
  void addChangeListener(void Function() function) =>
      changeListeners.add(function);
  void addCleanListener(void Function() function) =>
      cleanListeners.add(function);

  void notifyListeners(List<void Function()> listeners) {
    for (var element in listeners) {
      element();
    }
  }

  void notifyRemoveListeners(int val) {
    for (var el in removeListener) {
      el(val);
    }
  }
}
