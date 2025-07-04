import 'package:flutter/material.dart';
import '../models/category.dart';

/// Shows a folder or table tile in a 2‑column grid.
/// Long‑press  ➔  pops up “Rename” / “Delete”.
class GridCategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;           // ← NEW

  const GridCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    required this.onDelete,
    required this.onRename,                     // ← NEW
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),  // ← replace _confirmDelete
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 3),
              spreadRadius: 1,
              color: Colors.black12,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: category.type == CategoryType.folder
                ? _buildFolderLayout()
                : _buildTableLayout(),
          ),
        ),
      ),
    );
  }

  /* ───────────────── FOLDER LAYOUT ───────────────── */
  Widget _buildFolderLayout() {
    // Optionally shrink icon for very long labels
    final iconSize = category.label.length > 12 ? 40.0 : 48.0;

    return Row(
      children: [
        Icon(category.icon, size: iconSize),
        const SizedBox(width: 16),
        Container(width: 2, height: 60, color: Colors.grey.shade300),
        const SizedBox(width: 16),
        Expanded(
          child: FittedBox(               // auto‑shrink long text
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              category.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  /* ───────────────── TABLE LAYOUT ───────────────── */
  Widget _buildTableLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(category.icon, size: 36),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            category.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /* ───────── Options dialog (Rename / Delete) ───────── */
  void _showOptions(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename'),
            onTap: () async {
              Navigator.pop(ctx); // close sheet
              final newName = await _renameDialog(ctx);
              if (newName != null && newName.trim().isNotEmpty) {
                onRename(newName.trim());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx); // close sheet
              _confirmDelete(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _renameDialog(BuildContext ctx) async {
    final ctrl = TextEditingController(text: category.label);
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Do you want to delete this category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
