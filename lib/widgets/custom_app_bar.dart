import 'package:flutter/material.dart';

class MyGameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDrawerButton;
  final bool showBackButton;

  const MyGameAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showDrawerButton = false,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      elevation: 4,
      automaticallyImplyLeading: false,
      leading: showDrawerButton
          ? IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      )
          : (showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      )
          : null),
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(Icons.videogame_asset, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: actions, // no default icons, now only shows if you pass custom actions
    );
  }
}
