import 'package:flutter/material.dart';

import '../models/category.dart';
import '../widgets/add_category_dialog.dart';
import '../pages/category_page.dart';
import '../pages/table_page.dart';
import '../widgets/category_tile.dart';
import '../widgets/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Category> _rootCategories = [];

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(
        pageTitle: 'Home',
        onCreate: (cat) => setState(() => _rootCategories.add(cat)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyGameAppBar(
        title: 'MyGameList',
        showDrawerButton: false,
        showBackButton: false,
      ),
      body: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Baseline(
                  baseline: 40,
                  baselineType: TextBaseline.alphabetic,
                  child: Text('Welcome',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 8),
                Text('Ryzen',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _rootCategories.isEmpty
                  ? const Center(child: Text('No categories yet.'))
                  : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: _rootCategories.map((cat) {
                      return CategoryTile(
                        category: cat,
                        onDelete: () => setState(() => _rootCategories.remove(cat)),
                        onRename: (newName) => setState(() => cat.label = newName),
                        onTap: () {
                          if (cat.type == CategoryType.folder) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryPage(
                                  category: cat,
                                  onChanged: () => setState(() {}),
                                  breadcrumbs: ['Home', cat.label],
                                  pathCats: [cat],
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TablePage(
                                  tableCat: cat,
                                  breadcrumbs: ['Home', cat.label],
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
            ),
          ],
        ),
      ),
    );
  }
}