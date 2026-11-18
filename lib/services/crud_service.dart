import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudService {
  // Reference to the 'items' collection in the Firestore database
  late final CollectionReference _itemsCollection;

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

  // CREATE - Add a new item to Firestore
  Future<void> addItem(String name, String quantity) async {
    try {
      await _itemsCollection.add({
        'name': name,
        'quantity': quantity,
        'isFavorite': false,
      });
    } catch (e) {
      rethrow;
    }
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
