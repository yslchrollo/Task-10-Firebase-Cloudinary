import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/crud_service.dart';
import '../services/auth_service.dart';
import '../widgets/item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instance of our CRUD service
  final CrudService _crudService = CrudService();
  final AuthService _authService = AuthService();

  // Track whether the favorites filter is active
  bool _showFavoritesOnly = false;

  // ─── SIGN OUT ─────────────────────────────────────────────────────────────
  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      // StreamBuilder in main.dart will automatically navigate to LoginPage
    }
  }

  // ───────────────────────────────────────────────
  // ADD ITEM DIALOG
  // ───────────────────────────────────────────────
  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final quantity = quantityController.text.trim();

                          if (name.isEmpty || quantity.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _crudService.addItem(name, quantity);
                            nameController.clear();
                            quantityController.clear();

                            // Automatically close the dialog after successful save
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item added successfully!'),
                                  backgroundColor: Colors.teal,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            // Keep dialog open on failure and show error
                            setDialogState(() {
                              isSubmitting = false;
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save item: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // EDIT ITEM DIALOG
  // ───────────────────────────────────────────────
  void _showEditItemDialog(
    String docId,
    String currentName,
    String currentQuantity,
  ) {
    final nameController = TextEditingController(text: currentName);
    final quantityController = TextEditingController(text: currentQuantity);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final quantity = quantityController.text.trim();

                          if (name.isEmpty || quantity.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _crudService.updateItem(docId, name, quantity);

                            // Automatically close the dialog after successful edit
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item updated successfully!'),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            // Keep dialog open on failure and show error
                            setDialogState(() {
                              isSubmitting = false;
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update item: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // DELETE CONFIRMATION DIALOG
  // ───────────────────────────────────────────────
  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Delete Item'),
              content: const Text('Are you sure you want to delete this item?'),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() {
                            isDeleting = true;
                          });

                          try {
                            await _crudService.deleteItem(docId);

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item deleted successfully!'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isDeleting = false;
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete item: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // BUILD METHOD
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ──
      appBar: AppBar(
        title: const Text('RODRIGO'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // ── Favorites Filter Toggle ──
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : Colors.white,
            ),
            tooltip: 'Filter Favorites',
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          // ── Logout Button ──
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),

      // ── Body: gray background with item list ──
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
        stream: _crudService.getItems(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Firestore Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // No data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No items yet. Tap + to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Filter items based on favorite status if filter is active
          final allDocs = snapshot.data!.docs;
          final docs = _showFavoritesOnly
              ? allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['isFavorite'] == true;
                }).toList()
              : allDocs;

          if (docs.isEmpty && _showFavoritesOnly) {
            return const Center(
              child: Text(
                'No favorite items yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // ── Item List ──
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String name = data['name'] ?? '';
              final String quantity = data['quantity']?.toString() ?? '';
              final bool isFavorite = data['isFavorite'] ?? false;

              return ItemCard(
                name: name,
                quantity: quantity,
                isFavorite: isFavorite,
                onFavoriteToggle: () async {
                  try {
                    await _crudService.toggleFavorite(doc.id, isFavorite);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update favorite: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                onEdit: () {
                  _showEditItemDialog(doc.id, name, quantity);
                },
                onDelete: () {
                  _showDeleteConfirmationDialog(doc.id);
                },
              );
            },
          );
        },
      ),

      // ── Floating Action Button ──
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
