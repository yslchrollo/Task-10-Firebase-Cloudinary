import 'package:material_ui/material_ui.dart';

/// A card representing a single item in the inventory list.
/// Displays the item's optional thumbnail image, name, quantity, and three action icons:
/// 1. Heart (favorite toggle)
/// 2. Pencil (edit)
/// 3. Trash (delete)
class ItemCard extends StatelessWidget {
  final String name;
  final String quantity;
  final bool isFavorite;
  final String? imageUrl;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.isFavorite,
    this.imageUrl,
    required this.onFavoriteToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        // Item thumbnail on the left (matching professor's demonstration)
        leading: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.teal,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file,
                      color: Colors.teal,
                    ),
                  ),
                ),
              )
            : null,
        // Item name
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        // Item quantity
        subtitle: Text(
          'Quantity $quantity',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        // Action icons on the right
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ❤️ Favorite toggle
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
            // ✏️ Edit button
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.orange,
              ),
              onPressed: onEdit,
            ),
            // 🗑️ Delete button
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
