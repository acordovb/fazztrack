import 'package:flutter/material.dart';
import 'package:fazztrack_app/services/local_storages/bar_storage_service.dart';
import 'package:fazztrack_app/pages/init/bar_selection_screen.dart';
import 'package:fazztrack_app/pages/procedures/base_procedures_screen.dart';

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
          return const BaseProceduresScreen(title: 'Fazztrack App');
        } else {
          return BarSelectionScreen(
            nextScreen: const BaseProceduresScreen(title: 'Fazztrack App'),
          );
        }
      },
    );
  }
}
