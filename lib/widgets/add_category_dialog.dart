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
  /* step‑1 variables (common) */
  String _name = '';
  IconData? _icon;
  CategoryType _type = CategoryType.folder;

  /* step‑2 variables (tables only) */
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
      title: Text('New in ${widget.pageTitle}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* ------------- STEP‑1 (common) ------------- */
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _name = v),
            ),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected: [
                _type == CategoryType.folder,
                _type == CategoryType.table
              ],
              onPressed: (i) => setState(() =>
              _type = i == 0 ? CategoryType.folder : CategoryType.table),
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
              children: _iconChoices.map((icon) {
                final selected = icon == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = icon),
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

            /* ------------- STEP‑2 (only for tables) ------------- */
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
                                : TextEditingController());
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
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}), // 🛠️ Add this line
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
            child: const Text('Cancel')),
        ElevatedButton(
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
