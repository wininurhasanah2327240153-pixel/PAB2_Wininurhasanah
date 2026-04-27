import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteDialog extends StatefulWidget {
  final Note? note; // null = add mode, not null = edit mode

  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final NoteService _noteService = NoteService();
  final ImagePicker _picker = ImagePicker();

  String? _imageBase64;
  bool _isLoading = false;

  bool get _isEditMode => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _imageBase64 = widget.note!.imageBase64;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBase64 = null;
    });
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageBase64: _imageBase64,
        createdAt: widget.note?.createdAt,
      );

      if (_isEditMode) {
        await _noteService.updateNote(note);
      } else {
        await _noteService.addNote(note);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan catatan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      _isEditMode ? Icons.edit_note : Icons.note_add,
                      color: Colors.deepPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditMode ? 'Edit Note' : 'Add Note',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'Masukkan judul catatan',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Masukkan deskripsi catatan',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Description tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Image section
                        if (_imageBase64 != null) ...[
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(_imageBase64!),
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.red.shade600,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 18, color: Colors.white),
                                    onPressed: _removeImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Pick image button
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: Text(
                            _imageBase64 != null
                                ? 'Ganti Gambar'
                                : 'Pilih Gambar',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Update' : 'Simpan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
