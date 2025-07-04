import 'package:flutter/material.dart';

/* ---------- TABLE SUPPORT ---------- */
class TableInfo {
  List<String> columns;          // e.g. ["Title", "Genre", "Hours"]
  List<List<String>> rows = [];  // each row has N strings matching columns

  TableInfo(this.columns);
}

/* ---------- CATEGORY ---------- */
class Category {
  String label;
  IconData icon;
  CategoryType type;
  List<Category> children;    // used only when type == folder
  TableInfo? tableInfo;       // used only when type == table

  Category({
    required this.label,
    required this.icon,
    required this.type,
    List<Category>? children,   // <── accept nullable
    this.tableInfo,
  }) : children = children ?? [];   // <── create a *new* growable list
}

enum CategoryType { folder, table }
