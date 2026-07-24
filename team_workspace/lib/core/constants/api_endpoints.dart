class ApiEndpoints {
  const ApiEndpoints._();

  static const String tasks = 'tasks';

  static String taskById(int id) => 'tasks?id=eq.$id';
}
