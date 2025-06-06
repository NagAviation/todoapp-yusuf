import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

enum TodoFilter { all, completed, notCompleted }

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      final response =
          await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        state = data.map((e) => Todo.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

  void toggleCompleted(int id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(completed: !todo.completed)
        else
          todo
    ];
  }

  void deleteTodo(int id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void deleteMultiple(List<int> ids) {
    state = state.where((todo) => !ids.contains(todo.id)).toList();
  }

  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      completed: false,
    );
    state = [...state, newTodo];
  }

  void editTodo(int id, String newTitle) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(title: newTitle)
        else
          todo
    ];
  }

  void duplicateTodo(int id) {
    final todoToDuplicate = state.firstWhere((todo) => todo.id == id);
    final duplicated = Todo(
      id: DateTime.now().millisecondsSinceEpoch,
      title: todoToDuplicate.title + " (copy)",
      completed: todoToDuplicate.completed,
    );
    state = [...state, duplicated];
  }
}
