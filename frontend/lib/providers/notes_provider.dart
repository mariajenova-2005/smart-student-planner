import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/api_service.dart';

class NotesProvider with ChangeNotifier {
  List<NoteModel> _notes = [];
  final ApiService _api = ApiService();

  List<NoteModel> get notes => _notes;
  List<String> get subjects => _notes.map((n) => n.subject).toSet().toList()..sort();
  List<NoteModel> getNotesBySubject(String s) => _notes.where((n) => n.subject == s).toList();

  Future<void> loadNotes() async {
    final result = await _api.getNotes();
    if (result['success'] == true) {
      final list = result['notes'] as List<dynamic>;
      _notes = list.map((j) => NoteModel.fromJson(j as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> addNote({required String subject, required String title, required String content}) async {
    final result = await _api.createNote({'subject': subject, 'title': title, 'content': content});
    if (result['success'] == true) {
      _notes.insert(0, NoteModel.fromJson(result['note'] as Map<String, dynamic>));
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    final ok = await _api.deleteNote(noteId);
    if (ok) {
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
    }
  }

  void clearNotes() {
    _notes = [];
    notifyListeners();
  }
}
