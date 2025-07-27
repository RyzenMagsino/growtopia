import 'package:flutter/material.dart';
import '../models/category.dart';

class AddCategoryDialog extends StatefulWidget {
  final String pageTitle;
  final void Function(Category) onCreate;

  const AddCategoryDialog({
    super.key,
    required this.pageTitle,
    required this.onCreate,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  String _name = '';
  IconData? _icon;
  CategoryType _type = CategoryType.folder;

  int _colCount = 1;
  List<TextEditingController> _colCtrls = [TextEditingController()];

  final _iconChoices = const [
    Icons.extension,
    Icons.star,
    Icons.sports_esports,
    Icons.flag,
    Icons.bookmark,
    Icons.calendar_month,
    Icons.favorite_border,
  ];

  bool get _isStep2 => _type == CategoryType.table;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE6D9FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF7A42F4), width: 3),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/images/growtopia.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'New in ${widget.pageTitle}',
              style: const TextStyle(
                fontFamily: 'PixelifySans',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF7A42F4),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Step 1: Title ──────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 6), // Added top padding here
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => _name = v),
              ),
            ),
            const SizedBox(height: 12),

            // ── Step 1: Toggle Buttons ─────────────
            ToggleButtons(
              isSelected: [
                _type == CategoryType.folder,
                _type == CategoryType.table
              ],
              onPressed: (i) => setState(() =>
              _type = i == 0 ? CategoryType.folder : CategoryType.table),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              color: Colors.black87,
              fillColor: const Color(0xFFB388FF),
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

            // ── Step 1: Icon Choices ───────────────
            // ── Step 1: Icon Choices ───────────────
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _iconChoices.map((icon) {
                final selected = icon == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Colors.deepPurple.withOpacity(0.1) // LESS intense
                          : Colors.white,
                      border: Border.all(
                        color: selected
                            ? Colors.deepPurple.shade200 // Lighter border
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.15), // Subtle glow
                            blurRadius: 3, // Smaller blur
                            offset: const Offset(1, 2),
                          )
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: selected ? Colors.deepPurple : Colors.black54,
                    ),
                  ),
                );
              }).toList(),
            ),


            // ── Step 2: Columns ─────────────────────
            if (_isStep2) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Text('Columns:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _colCount,
                    items: List.generate(
                      10,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _colCount = v;
                        _colCtrls = List.generate(
                          v,
                              (i) => i < _colCtrls.length
                              ? _colCtrls[i]
                              : TextEditingController(),
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _colCount,
                    (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _colCtrls[i],
                    decoration: InputDecoration(
                      labelText: 'Column ${i + 1}',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB388FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _canSubmit ? _createCategory : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  bool get _canSubmit {
    if (_name.trim().isEmpty || _icon == null) return false;
    if (!_isStep2) return true;
    return _colCtrls.every((c) => c.text.trim().isNotEmpty);
  }

  void _createCategory() {
    final cat = Category(
      label: _name.trim(),
      icon: _icon!,
      type: _type,
      tableInfo: _isStep2
          ? TableInfo(_colCtrls.map((c) => c.text.trim()).toList())
          : null,
    );
    widget.onCreate(cat);
    Navigator.pop(context);
  }
}
