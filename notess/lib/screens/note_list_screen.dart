import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/note_dialog.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteService _noteService = NoteService();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const NoteDialog(),
    );
  }

  void _showEditDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) => NoteDialog(note: note),
    );
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Catatan'),
        content: Text('Apakah Anda yakin ingin menghapus "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (note.id != null) {
                await _noteService.deleteNote(note.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan berhasil dihapus')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _noteService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada catatan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah catatan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteCard(note);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (note.imageBase64 != null && note.imageBase64!.isNotEmpty)
            Image.memory(
              base64Decode(note.imageBase64!),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  note.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Date
                    Expanded(
                      child: Text(
                        _formatDate(note.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () => _showEditDialog(note),
                      tooltip: 'Edit',
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(note),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
