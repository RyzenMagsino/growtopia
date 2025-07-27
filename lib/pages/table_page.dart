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
    for (int i = 0; i < _t.columns.length; i++) i: const FlexColumnWidth(),
    _t.columns.length: const FlexColumnWidth(0.8), // Actions column
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyGameAppBar(title: widget.tableCat.label),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildBreadcrumbBar()),
                ElevatedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbBar() {
    return Wrap(
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
    );
  }

  void _popToLevel(int index) {
    final pops = widget.breadcrumbs.length - 1 - index;
    for (int i = 0; i < pops; i++) {
      Navigator.pop(context);
    }
  }

  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade500,
                      width: 1.5,
                    ),
                    columnWidths: _columnWidths,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _buildHeaderRow(),
                      ...List.generate(_t.rows.length, _buildDataRow),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _buildHeaderRow() => TableRow(
    decoration: BoxDecoration(color: Colors.grey.shade200),
    children: [
      ..._t.columns.map((c) => _cell(
          Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))),
      _cell(const Text('Actions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
    ],
  );

  TableRow _buildDataRow(int rowIdx) {
    final row = _t.rows[rowIdx];

    return TableRow(
      children: List.generate(_t.columns.length + 1, (colIdx) {
        if (colIdx == _t.columns.length) {
          return _cell(
            Center(
              child: IconButton(
                icon: const Icon(Icons.edit, size: 28, color: Colors.blue),
                onPressed: () => _editRow(rowIdx),
                tooltip: 'Edit row',
              ),
            ),
          );
        }

        final cellValue = row[colIdx];
        final shouldToggle =
            cellValue.trim().isEmpty || cellValue == 'Ready' || cellValue == 'Not';

        return shouldToggle
            ? _buildTogglingCell(rowIdx, colIdx, cellValue)
            : _cell(Text(cellValue));
      }),
    );
  }

  Widget _buildTogglingCell(int rowIdx, int colIdx, String value) {
    return _cell(
      FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: value == 'Ready' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Mark as Ready',
              onPressed: () {
                setState(() => _t.rows[rowIdx][colIdx] = 'Ready');
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Mark as Not',
              onPressed: () {
                setState(() => _t.rows[rowIdx][colIdx] = 'Not');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(Widget child) => Padding(
    padding: const EdgeInsets.all(12),
    child: Center(child: child),
  );

  void _addRow() =>
      _rowDialog(onSave: (newRow) => setState(() => _t.rows.add(newRow)));

  void _editRow(int idx) => _rowDialog(
    initial: _t.rows[idx],
    onSave: (newRow) => setState(() => _t.rows[idx] = newRow),
    onDelete: () => setState(() => _t.rows.removeAt(idx)),
  );

  void _rowDialog({
    List<String>? initial,
    required void Function(List<String>) onSave,
    void Function()? onDelete,
  }) {
    final ctrls = List.generate(
        _t.columns.length, (i) => TextEditingController(text: initial?[i] ?? ''));

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
                  decoration: InputDecoration(
                    labelText: _t.columns[i],
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (initial != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDelete?.call();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
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
