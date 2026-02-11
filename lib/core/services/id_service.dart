class IdService {
  IdService._();

  static int _seed = DateTime.now().microsecondsSinceEpoch;

  static String nextId() => (_seed++).toString();
}
