import 'package:flutter/material.dart';
import '../models/category.dart';
import '../widgets/add_category_dialog.dart';
import '../pages/table_page.dart';
import '../widgets/grid_category_tile.dart';
import '../widgets/custom_app_bar.dart';

class CategoryPage extends StatefulWidget {
  final Category category;
  final VoidCallback onChanged;
  final List<String> breadcrumbs;      // label path
  final List<Category> pathCats;       // actual category objects in path (excluding Home)

  const CategoryPage({
    super.key,
    required this.category,
    required this.onChanged,
    required this.breadcrumbs,
    required this.pathCats,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(
        pageTitle: widget.category.label,
        onCreate: (cat) {
          setState(() => widget.category.children.add(cat));
          widget.onChanged();
        },
      ),
    );
  }

  void _navigateToBreadcrumb(int index) {
    // index 0 == Home → just pop to root
    Navigator.popUntil(context, (route) => route.isFirst);
    if (index == 0) return;

    // push CategoryPages for pathCats up to index
    for (int i = 0; i < index; i++) {
      final cat = widget.pathCats[i];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryPage(
            category: cat,
            onChanged: widget.onChanged,
            breadcrumbs: widget.breadcrumbs.sublist(0, i + 2),
            pathCats: widget.pathCats.sublist(0, i + 1),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyGameAppBar(title: widget.category.label),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Wrap(
              spacing: 4,
              children: List.generate(widget.breadcrumbs.length, (i) {
                final label = widget.breadcrumbs[i];
                final isLast = i == widget.breadcrumbs.length - 1;
                return GestureDetector(
                  onTap: isLast ? null : () => _navigateToBreadcrumb(i),
                  child: Text(
                    isLast ? label : '$label >',
                    style: TextStyle(
                      color: isLast ? Colors.grey : Colors.deepPurple,
                      fontWeight: isLast ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.category.children.isEmpty
                  ? const Center(child: Text('Empty folder.'))
                  : GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1.2,
                children: widget.category.children.map((cat) {
                  return GridCategoryTile(
                    category: cat,
                    onDelete: () {            // existing
                      setState(() => widget.category.children.remove(cat));
                      widget.onChanged();
                    },
                    onRename: (newName) {     // ← NEW
                      setState(() => cat.label = newName);
                      widget.onChanged();
                    },
                    onTap: () {
                      if (cat.type == CategoryType.folder) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryPage(
                              category: cat,
                              onChanged: () => setState(() {}),
                              breadcrumbs: [...widget.breadcrumbs, cat.label],
                              pathCats: [...widget.pathCats, cat],
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TablePage(
                              tableCat: cat,
                              breadcrumbs: [...widget.breadcrumbs, cat.label],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}