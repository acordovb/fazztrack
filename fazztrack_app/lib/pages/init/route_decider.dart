import 'package:flutter/material.dart';
import 'package:fazztrack_app/services/bar_storage_service.dart';
import 'package:fazztrack_app/pages/init/bar_selection_screen.dart';
import 'package:fazztrack_app/pages/procedures/base_procedures.dart';

class RouteDecider extends StatelessWidget {
  const RouteDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: BarStorageService.hasSelectedBar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSelectedBar = snapshot.data ?? false;

        if (hasSelectedBar) {
          return const BaseProcedures(title: 'Fazztrack App');
        } else {
          return BarSelectionScreen(
            nextScreen: const BaseProcedures(title: 'Fazztrack App'),
          );
        }
      },
    );
  }
}
