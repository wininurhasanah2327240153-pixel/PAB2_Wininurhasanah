import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final CollectionReference _notesCollection =
      FirebaseFirestore.instance.collection('notes');

  /// Get all notes as a real-time stream, ordered by createdAt descending
  Stream<List<Note>> getNotes() {
    return _notesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  /// Add a new note to Firestore
  Future<void> addNote(Note note) async {
    await _notesCollection.add(note.toFirestore());
  }

  /// Update an existing note in Firestore
  Future<void> updateNote(Note note) async {
    if (note.id == null) return;
    await _notesCollection.doc(note.id).update(note.toFirestore());
  }

  /// Delete a note from Firestore
  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }
}
