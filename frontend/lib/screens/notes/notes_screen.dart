import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String? _selectedSubject;

  final List<Color> _colors = const [
    Color(0xFF6C63FF), Color(0xFFE91E8C), Color(0xFF00ACC1),
    Color(0xFFFFA726), Color(0xFF43A047), Color(0xFFE53935),
  ];

  Color _colorFor(String s, List<String> subjects) => _colors[subjects.indexOf(s) % _colors.length];

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NotesProvider>();
    final subjects = np.subjects;
    final notes = _selectedSubject != null ? np.getNotesBySubject(_selectedSubject!) : np.notes;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          if (subjects.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _Chip(label: 'All', color: const Color(0xFF6C63FF), selected: _selectedSubject == null, onTap: () => setState(() => _selectedSubject = null)),
                  ...subjects.map((s) => _Chip(
                    label: s, color: _colorFor(s, subjects), selected: _selectedSubject == s,
                    onTap: () => setState(() => _selectedSubject == s ? _selectedSubject = null : _selectedSubject = s),
                  )),
                ],
              ),
            ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.note_outlined, size: 60, color: Color(0xFF6C63FF)),
                    SizedBox(height: 16),
                    Text('No notes yet', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Tap + to add a note', style: TextStyle(color: Colors.grey)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _NoteCard(note: notes[i], color: _colorFor(notes[i].subject, subjects)),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context, isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const _AddNoteSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: selected ? color : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final Color color;
  const _NoteCard({required this.note, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showModalBottomSheet(
          context: context, isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => _ViewSheet(note: note),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(note.subject, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                onSelected: (v) { if (v == 'delete') context.read<NotesProvider>().deleteNote(note.id); },
                itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red)))],
              ),
            ]),
            const SizedBox(height: 8),
            Text(note.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(note.content, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(DateFormat('MMM d, yyyy').format(note.updatedAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          ]),
        ),
      ),
    );
  }
}

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet();
  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _subjectCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() { _subjectCtrl.dispose(); _titleCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Note', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: 'Subject *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter subject' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _contentCtrl, maxLines: 4,
              decoration: const InputDecoration(labelText: 'Content *', alignLabelWithHint: true),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter content' : null),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final np = context.read<NotesProvider>();
                await np.addNote(subject: _subjectCtrl.text.trim(), title: _titleCtrl.text.trim(), content: _contentCtrl.text.trim());
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save Note'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ViewSheet extends StatelessWidget {
  final NoteModel note;
  const _ViewSheet({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.6, maxChildSize: 0.95,
      builder: (ctx, scroll) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(controller: scroll, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(note.subject, style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Text(note.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(DateFormat('MMMM d, yyyy').format(note.updatedAt), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
          const Divider(height: 24),
          Text(note.content, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
