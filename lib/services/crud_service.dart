import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';

class PickedImage {
  final File file;
  final String url;
  final String fileName;
  final bool isImage;

  PickedImage({
    required this.file,
    required this.url,
    required this.fileName,
    this.isImage = true,
  });
}

class CrudService {
  // Reference to the 'items' collection in the Firestore database
  late final CollectionReference _itemsCollection;

  // Cloudinary configuration (Cloud Name & Unsigned Upload Preset)
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dr48cdvg',
    'rodrigo_crud',
    cache: false,
  );

  static const List<String> _imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  ];

  static const List<String> _supportedExtensions = [
    ..._imageExtensions,
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  CrudService() {
    // Note: The Firestore database in this project is named 'default'.
    // We connect to databaseId: 'default' (or fallback to instance) so it
    // communicates directly with the online Firestore instance on the server.
    FirebaseFirestore firestore;
    try {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      );
    } catch (_) {
      firestore = FirebaseFirestore.instance;
    }
    _itemsCollection = firestore.collection('items');
  }

  // PICK IMAGE OR FILE FROM LOCAL STORAGE & UPLOAD TO CLOUDINARY
  Future<PickedImage?> pickImageForAddItem() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _supportedExtensions,
      allowMultiple: false,
    );

    // User cancelled the file picker
    if (result == null || result.files.isEmpty) return null;

    final PlatformFile pickedFile = result.files.single;
    final String? filePath = pickedFile.path;
    if (filePath == null || filePath.isEmpty) return null;

    final String ext = (pickedFile.extension ?? '').toLowerCase();
    if (!_supportedExtensions.contains(ext)) {
      throw FormatException(
        'Unsupported file format: .$ext. Supported formats: ${_supportedExtensions.join(', ')}',
      );
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw const FileSystemException('Selected file could not be accessed.');
    }

    final bool isImage = _imageExtensions.contains(ext);

    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: isImage
            ? CloudinaryResourceType.Image
            : CloudinaryResourceType.Auto,
      ),
    );

    return PickedImage(
      file: file,
      url: response.secureUrl,
      fileName: pickedFile.name,
      isImage: isImage,
    );
  }

  // CREATE - Add a new item with optional image/file URL to Firestore
  Future<void> addItemWithImage(
    String name,
    String quantity,
    String? imageUrl, {
    String? fileName,
  }) async {
    try {
      await _itemsCollection.add({
        'name': name,
        'quantity': quantity,
        'image_url': imageUrl,
        'file_name': ?fileName,
        'isFavorite': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // CREATE - Add a new item to Firestore (without image)
  Future<void> addItem(String name, String quantity) async {
    return addItemWithImage(name, quantity, null);
  }

  // READ - Get all items as a real-time stream
  Stream<QuerySnapshot> getItems() {
    return _itemsCollection.snapshots();
  }

  // UPDATE - Update an existing item in Firestore
  Future<void> updateItem(String docId, String name, String quantity) async {
    try {
      await _itemsCollection.doc(docId).update({
        'name': name,
        'quantity': quantity,
      });
    } catch (e) {
      rethrow;
    }
  }

  // DELETE - Delete an item from Firestore
  Future<void> deleteItem(String docId) async {
    try {
      await _itemsCollection.doc(docId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // TOGGLE FAVORITE - Toggle the isFavorite field
  Future<void> toggleFavorite(String docId, bool currentStatus) async {
    try {
      await _itemsCollection.doc(docId).update({
        'isFavorite': !currentStatus,
      });
    } catch (e) {
      rethrow;
    }
  }

  // SIGN OUT - Convenience method to sign out
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
