import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/* ───────────────────────────────────────────────────────────
   DATA MODEL
─────────────────────────────────────────────────────────── */
class Category {
  String label;
  IconData icon;
  CategoryType type;
  List<Category> children;

  Category({
    required this.label,
    required this.icon,
    required this.type,
    List<Category>? children,
  }) : children = children ?? [];
}

enum CategoryType { folder, table }

/* ───────────────────────────────────────────────────────────
   APP ROOT
─────────────────────────────────────────────────────────── */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyGameList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: const HomePage(),
    );
  }
}

/* ───────────────────────────────────────────────────────────
   HOME PAGE  (root folder)
─────────────────────────────────────────────────────────── */
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Category> _rootCategories = []; // start empty

  /* dialog reused by root */
  Future<void> _openAddDialog(
      List<Category> targetList, String pageTitle) async {
    String name = '';
    IconData? chosenIcon;
    CategoryType chosenType = CategoryType.folder;

    const iconChoices = [
      Icons.extension,
      Icons.star,
      Icons.sports_esports,
      Icons.flag,
      Icons.bookmark,
      Icons.calendar_month,
      Icons.favorite_border,
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInner) => AlertDialog(
            title: Text('New in $pageTitle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 12),
                  ToggleButtons(
                    isSelected: [
                      chosenType == CategoryType.folder,
                      chosenType == CategoryType.table
                    ],
                    onPressed: (i) => setInner(() => chosenType =
                    i == 0 ? CategoryType.folder : CategoryType.table),
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Folder'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Table'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: iconChoices.map((icon) {
                      final selected = icon == chosenIcon;
                      return GestureDetector(
                        onTap: () => setInner(() => chosenIcon = icon),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2)
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                          child: Icon(icon,
                              size: 28,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black54),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (name.trim().isEmpty || chosenIcon == null)
                    ? null
                    : () {
                  setState(() {
                    targetList.add(Category(
                      label: name.trim(),
                      icon: chosenIcon!,
                      type: chosenType,
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ----------------- BUILD ----------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('MyGameList'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text('Welcome',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                SizedBox(width: 8),
                Text('Ryzen',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _openAddDialog(_rootCategories, 'Home'),
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
                    children: _rootCategories
                        .map((cat) => CategoryTile(
                      category: cat,
                      onDelete: () =>
                          setState(() => _rootCategories.remove(cat)),
                      onTap: () {
                        if (cat.type == CategoryType.folder) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPage(
                                category: cat,
                                onChanged: () => setState(() {}),
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TablePage(title: cat.label),
                            ),
                          );
                        }
                      },
                    ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(String title) => AppBar(
    elevation: 3,
    surfaceTintColor: Colors.white,
    backgroundColor: Colors.white,
    shadowColor: Colors.black12,
    title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold)),
    actions: [
      IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: () {},
      ),
      const SizedBox(width: 8),
    ],
  );
}

/* ───────────────────────────────────────────────────────────
   CATEGORY PAGE  (sub-folder) — UPDATED
─────────────────────────────────────────────────────────── */
class CategoryPage extends StatefulWidget {
  final Category category;
  final VoidCallback onChanged; // notify ancestors

  const CategoryPage({
    super.key,
    required this.category,
    required this.onChanged,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Future<void> _openAddDialog() async {
    String name = '';
    IconData? chosenIcon;
    CategoryType chosenType = CategoryType.folder;

    const iconChoices = [
      Icons.extension,
      Icons.star,
      Icons.sports_esports,
      Icons.flag,
      Icons.bookmark,
      Icons.calendar_month,
      Icons.favorite_border,
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInner) => AlertDialog(
            title: Text('New in ${widget.category.label}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 12),
                  ToggleButtons(
                    isSelected: [
                      chosenType == CategoryType.folder,
                      chosenType == CategoryType.table
                    ],
                    onPressed: (i) => setInner(() => chosenType =
                    i == 0 ? CategoryType.folder : CategoryType.table),
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Folder'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Table'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: iconChoices.map((icon) {
                      final selected = icon == chosenIcon;
                      return GestureDetector(
                        onTap: () => setInner(() => chosenIcon = icon),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2)
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                          child: Icon(icon,
                              size: 28,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black54),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (name.trim().isEmpty || chosenIcon == null)
                    ? null
                    : () {
                  setState(() {
                    widget.category.children.add(Category(
                      label: name.trim(),
                      icon: chosenIcon!,
                      type: chosenType,
                    ));
                  });
                  widget.onChanged(); // refresh ancestors
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ----------------- BUILD ----------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add in ${widget.category.label}',
            onPressed: _openAddDialog,
          )
        ],
      ),
      body: Padding(
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
              onDelete: () {
                setState(() => widget.category.children.remove(cat));
                widget.onChanged(); // update ancestor pages
              },
              onTap: () {
                if (cat.type == CategoryType.folder) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPage(
                        category: cat,
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TablePage(title: cat.label),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/* ───────────────────────────────────────────────────────────
   TABLE PAGE (placeholder)
─────────────────────────────────────────────────────────── */
class TablePage extends StatelessWidget {
  final String title;
  const TablePage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Table view for "$title" goes here',
            style:
            const TextStyle(fontSize: 18, color: Colors.black54)),
      ),
    );
  }
}

/* ───────────────────────────────────────────────────────────
   TILES — list & grid
─────────────────────────────────────────────────────────── */
class CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        width: 260,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 4),
              spreadRadius: 1,
              color: Colors.black12,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 28),
              const SizedBox(width: 12),
              Text(category.label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (category.type == CategoryType.folder)
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
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
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/* grid tile for folder pages */
class GridCategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GridCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 36),
              const SizedBox(height: 10),
              Text(category.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
