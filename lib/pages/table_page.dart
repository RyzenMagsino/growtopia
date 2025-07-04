import 'package:flutter/material.dart';
import '../models/category.dart';
import '../widgets/custom_app_bar.dart';

class TablePage extends StatefulWidget {
  final Category tableCat;
  final List<String> breadcrumbs;

  const TablePage({super.key, required this.tableCat, this.breadcrumbs = const ['Home']});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  TableInfo get _t => widget.tableCat.tableInfo!;

  late final Map<int, TableColumnWidth> _columnWidths = {
    for (int i = 0; i < _t.columns.length + 1; i++) i: const FixedColumnWidth(150)
  };

  /* ───────────────────────── BUILD ───────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyGameAppBar(title: widget.tableCat.label),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumbBar(),
          Expanded(child: _buildTable()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRow,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  /* ────────── Breadcrumb bar ────────── */
  Widget _buildBreadcrumbBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 4,
        children: List.generate(widget.breadcrumbs.length, (i) {
          final label = widget.breadcrumbs[i];
          final isLast = i == widget.breadcrumbs.length - 1;
          return GestureDetector(
            onTap: isLast ? null : () => _popToLevel(i),
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
    );
  }

  void _popToLevel(int index) {
    // number of pages to pop (not counting current one)
    final pops = widget.breadcrumbs.length - 1 - index;
    for (int i = 0; i < pops; i++) {
      Navigator.pop(context);
    }
  }

  /* ────────── Data table ────────── */
  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1),
            columnWidths: _columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _buildHeaderRow(),
              ...List.generate(_t.rows.length, _buildDataRow),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() => TableRow(
    decoration: BoxDecoration(color: Colors.grey.shade200),
    children: [
      ..._t.columns.map((c) => _cell(Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))),
      _cell(const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
    ],
  );

  TableRow _buildDataRow(int rowIdx) {
    final row = _t.rows[rowIdx];
    return TableRow(
      children: [
        ...row.map((v) => _cell(Text(v))),
        _cell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _editRow(rowIdx),
              tooltip: 'Edit row',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => setState(() => _t.rows.removeAt(rowIdx)),
              tooltip: 'Delete row',
            ),
          ],
        )),
      ],
    );
  }

  Widget _cell(Widget child) => Padding(padding: const EdgeInsets.all(12), child: child);

  /* ────────── Row dialogs ────────── */
  void _addRow() => _rowDialog(onSave: (newRow) => setState(() => _t.rows.add(newRow)));

  void _editRow(int idx) => _rowDialog(
    initial: _t.rows[idx],
    onSave: (newRow) => setState(() => _t.rows[idx] = newRow),
  );

  void _rowDialog({List<String>? initial, required void Function(List<String>) onSave}) {
    final ctrls = List.generate(_t.columns.length, (i) => TextEditingController(text: initial?[i] ?? ''));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(initial == null ? 'Add Row' : 'Edit Row'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _t.columns.length,
                  (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: ctrls[i],
                  decoration: InputDecoration(labelText: _t.columns[i], border: const OutlineInputBorder()),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onSave(ctrls.map((c) => c.text.trim()).toList());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}