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
        title: 'MyGrowtopiaList',
        showDrawerButton: false,
        showBackButton: false,
      ),
      backgroundColor: const Color(0xFFE6F2FF), // Light blue-ish background
      body: Stack(
        children: [
          // ── Top Background Image ──────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/growtopiabg.jpg',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

          // ── Main Body Content ─────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 160), // push down from background image
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Welcome Header ─────────────────────
                  Row(
                    children: const [
                      Baseline(
                        baseline: 40,
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Colors.indigo,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ryzen',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Add Button ────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: _openAddDialog,
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Category List or Message ──────────
                  Expanded(
                    child: _rootCategories.isEmpty
                        ? Center(
                      child: Text(
                        'No categories yet.',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                        : SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: _rootCategories.map((cat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CategoryTile(
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
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Left Growtopia Icon ───────────────
          Positioned(
            bottom: 10,
            left: 10,
            child: Image.asset(
              'assets/images/growtopia.png',
              width: 120,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}
