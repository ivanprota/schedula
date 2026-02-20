import 'package:flutter/material.dart';

class SchedulaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? height;

  const SchedulaAppBar({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double screenWidth = media.size.width;

    // Decidiamo una larghezza massima "responsive" per il logo
    double maxLogoWidth;
    if (screenWidth < 360) {
      // telefoni molto piccoli
      maxLogoWidth = screenWidth * 0.4;
    } else if (screenWidth < 600) {
      // telefoni "normali"
      maxLogoWidth = screenWidth * 0.5;
    } else if (screenWidth < 900) {
      // tablet piccoli
      maxLogoWidth = screenWidth * 0.35;
    } else {
      // tablet grandi / desktop
      maxLogoWidth = 320;
    }

    return AppBar(
      backgroundColor: Colors.indigo,
      centerTitle: true,
      title: ConstrainedBox(
        constraints: BoxConstraints(
          // il logo non potrà mai superare questa larghezza
          maxWidth: maxLogoWidth,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
            'assets/images/logo.png',
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // Se vuoi, puoi cambiare l’altezza in base all’orientamento
    // oppure usare sempre kToolbarHeight
    final double baseHeight = height ?? kToolbarHeight;
    return Size.fromHeight(baseHeight);
  }
}
