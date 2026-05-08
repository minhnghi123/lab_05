import "package:flutter/material.dart";
import "../api/api_client.dart";
import "../models/todo_item.dart";
import "../storage/auth_storage.dart";
import "login_screen.dart";

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _api = ApiClient();
  final List<TodoItem> _todos = [];
  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final userId = await AuthStorage.getUserId();
    if (!mounted) return;
    if (userId == null || userId.isEmpty) {
      await _logout();
      return;
    }
    setState(() => _userId = userId);
    await _loadTodos();
  }

  Future<void> _loadTodos() async {
    final userId = _userId;
    if (userId == null) return;
    setState(() => _loading = true);
    try {
      final items = await _api.getTodos(userId);
      if (!mounted) return;
      setState(() {
        _todos
          ..clear()
          ..addAll(items.reversed);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openEditor({TodoItem? item}) async {
    final result = await showModalBottomSheet<TodoDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TodoEditorSheet(initial: item),
    );

    if (result == null) return;

    try {
      if (item == null) {
        final created = await _api.createTodo(
          _userId!,
          result.title,
          result.description,
        );
        if (!mounted) return;
        setState(() => _todos.insert(0, created));
      } else {
        final updated = await _api.updateTodo(
          item.id,
          result.title,
          result.description,
        );
        if (!mounted) return;
        final index = _todos.indexWhere((todo) => todo.id == item.id);
        if (index != -1) {
          setState(() => _todos[index] = updated);
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _confirmDelete(TodoItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete task?"),
          content: const Text("This cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.deleteTodo(item.id);
      if (!mounted) return;
      setState(() => _todos.removeWhere((todo) => todo.id == item.id));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _logout() async {
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your focus list"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text("New task"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(
              "Shape your day with clear, focused tasks.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4C6663),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTodos,
                    child: _todos.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: 120),
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Color(0xFF9AA5A1),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "No tasks yet. Create your first one.",
                                  style: TextStyle(color: Color(0xFF6B7C78)),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                            itemCount: _todos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _todos[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ListTile(
                                  title: Text(
                                    item.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    item.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF4C6663),
                                    ),
                                  ),
                                  trailing: Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip: "Edit",
                                        onPressed: () =>
                                            _openEditor(item: item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: "Delete",
                                        onPressed: () => _confirmDelete(item),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class TodoDraft {
  const TodoDraft({required this.title, required this.description});

  final String title;
  final String description;
}

class TodoEditorSheet extends StatefulWidget {
  const TodoEditorSheet({super.key, this.initial});

  final TodoItem? initial;

  @override
  State<TodoEditorSheet> createState() => _TodoEditorSheetState();
}

class _TodoEditorSheetState extends State<TodoEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? "");
    _descriptionController = TextEditingController(
      text: widget.initial?.description ?? "",
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    Navigator.of(context).pop(
      TodoDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? "Create task" : "Update task",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration("Title"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Title is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration("Description"),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Description is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(widget.initial == null ? "Create" : "Save"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5F1EC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
