import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? id;
  final String title;
  final String description;
  final String? imageBase64;
  final DateTime createdAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.imageBase64,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a Note from a Firestore document snapshot
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageBase64: data['imageBase64'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Note to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageBase64': imageBase64,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy of this Note with updated fields
  Note copyWith({
    String? id,
    String? title,
    String? description,
    String? imageBase64,
    bool clearImage = false,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageBase64: clearImage ? null : (imageBase64 ?? this.imageBase64),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
