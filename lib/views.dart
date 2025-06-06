// views.dart (hanya bagian filter yang diubah)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'provider.dart';

enum TodoFilter { all, completed, notCompleted }

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  final TextEditingController addController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  TodoFilter filter = TodoFilter.all;

  @override
  void dispose() {
    addController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoListProvider);
    final notifier = ref.read(todoListProvider.notifier);

    // Filter todos based on filter enum
    List<Todo> filteredTodos;
    switch (filter) {
      case TodoFilter.completed:
        filteredTodos = todos.where((t) => t.completed).toList();
        break;
      case TodoFilter.notCompleted:
        filteredTodos = todos.where((t) => !t.completed).toList();
        break;
      case TodoFilter.all:
        filteredTodos = todos;
        break;
    }

    // Search filter
    if (searchController.text.isNotEmpty) {
      filteredTodos = filteredTodos
          .where((t) =>
              t.title.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List - Muhammad Yusuf')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search todos by title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // refresh UI on search input
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == TodoFilter.all,
                  onSelected: (selected) {
                    setState(() {
                      filter = TodoFilter.all;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: filter == TodoFilter.completed,
                  onSelected: (selected) {
                    setState(() {
                      filter = TodoFilter.completed;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Not Completed'),
                  selected: filter == TodoFilter.notCompleted,
                  onSelected: (selected) {
                    setState(() {
                      filter = TodoFilter.notCompleted;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(child: Text('No todos found'))
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.completed,
                          onChanged: (_) => notifier.toggleCompleted(todo.id),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration:
                                todo.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final editController =
                                    TextEditingController(text: todo.title);
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Edit Todo'),
                                    content: TextField(
                                      controller: editController,
                                      decoration: const InputDecoration(
                                          hintText: 'Edit title'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          notifier.editTodo(
                                              todo.id, editController.text);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => notifier.deleteTodo(todo.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: addController,
                decoration: const InputDecoration(hintText: 'Add new todo'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (addController.text.trim().isNotEmpty) {
                  notifier.addTodo(addController.text.trim());
                  addController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
