import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class TodoRepository {
  Future<List<Todo>> fetchTodos() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }
}
