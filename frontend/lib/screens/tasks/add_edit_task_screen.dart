import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});
  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  String _category = 'assignment';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _priority = widget.task!.priority;
      _category = widget.task!.category;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context, initialDate: _dueDate,
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dueDate));
    if (time == null || !mounted) return;
    setState(() { _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute); });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final taskProvider = context.read<TaskProvider>();
    if (_isEditing) {
      final updated = widget.task!
        ..title = _titleCtrl.text.trim()
        ..description = _descCtrl.text.trim()
        ..dueDate = _dueDate
        ..priority = _priority
        ..category = _category;
      await taskProvider.updateTask(updated);
    } else {
      await taskProvider.addTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
      );
    }
    if (mounted) { setState(() => _isLoading = false); context.go('/tasks'); }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.deleteTask(widget.task!.id);
      if (mounted) context.go('/tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.go('/tasks')),
        actions: [if (_isEditing) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _delete)],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Task title *', prefixIcon: Icon(Icons.title)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl, maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes), alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Due date & time'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF6C63FF), size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat('EEE, MMM d yyyy  •  h:mm a').format(_dueDate), style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    const Icon(Icons.edit_outlined, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Priority'),
              const SizedBox(height: 8),
              Row(
                children: AppConstants.priorities.map((p) {
                  final selected = _priority == p;
                  final color = AppTheme.priorityColor(p);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? color.withValues(alpha: 0.15) : theme.inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
                          ),
                          child: Column(children: [
                            Icon(Icons.flag, color: color, size: 20),
                            const SizedBox(height: 4),
                            Text(p[0].toUpperCase() + p.substring(1),
                              style: TextStyle(fontSize: 12, color: color, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                          ]),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Category'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: AppConstants.categories.map((cat) {
                  final selected = _category == cat;
                  final color = AppTheme.categoryColor(cat);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.15) : theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
                      ),
                      child: Text(cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(color: selected ? color : theme.colorScheme.onSurface, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Update Task' : 'Add Task'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600));
  }
}
