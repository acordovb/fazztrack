import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/pages/procedures/abono_screen.dart';
import 'package:flutter/material.dart';

import 'package:fazztrack_app/pages/procedures/consumo_screen.dart';
import 'package:fazztrack_app/pages/reports/reports_screen.dart';
import 'package:fazztrack_app/pages/admin/admin_screen.dart';
import 'package:fazztrack_app/config/build.config.dart';
import 'package:fazztrack_app/config/general.config.dart';

enum PageType { consumo, abono, reports, admin }

class BaseProceduresScreen extends StatefulWidget {
  const BaseProceduresScreen({super.key, required this.title});
  final String title;

  @override
  State<BaseProceduresScreen> createState() => _BaseProceduresScreenState();
}

class _BaseProceduresScreenState extends State<BaseProceduresScreen> {
  PageType _currentPage = PageType.consumo;

  final Map<PageType, String> _pageTitles = {
    PageType.consumo: 'Reportar Consumo',
    PageType.abono: 'Reportar Abono',
    PageType.reports: 'Reportes',
    PageType.admin: 'Administración',
  };

  void _changePage(PageType page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _getCurrentPageContent() {
    switch (_currentPage) {
      case PageType.consumo:
        return const ConsumoScreen();
      case PageType.abono:
        return const AbonoScreen();
      case PageType.reports:
        return const ReportsContent();
      case PageType.admin:
        return const AdminContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          _pageTitles[_currentPage] ?? widget.title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Menú principal',
              ),
        ),
      ),
      drawer: CustomDrawer(changePage: _changePage, currentPage: _currentPage),
      body: _getCurrentPageContent(),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.changePage,
    required this.currentPage,
  });

  final Function(PageType) changePage;
  final PageType currentPage;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app-logo-simple.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    title: 'Reportar Consumo',
                    icon: Icons.point_of_sale,
                    isSelected: currentPage == PageType.consumo,
                    onTap: () {
                      Navigator.pop(context);
                      changePage(PageType.consumo);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Reportar Abono',
                    icon: Icons.attach_money,
                    isSelected: currentPage == PageType.abono,
                    onTap: () {
                      Navigator.pop(context);
                      changePage(PageType.abono);
                    },
                  ),
                  if (BuildConfig.appLevel == AppConfig.appLevel.admin) ...[
                    _buildDrawerItem(
                      context: context,
                      title: 'Reportes',
                      icon: Icons.bar_chart,
                      isSelected: currentPage == PageType.reports,
                      onTap: () {
                        Navigator.pop(context);
                        changePage(PageType.reports);
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      title: 'Administración',
                      icon: Icons.admin_panel_settings,
                      isSelected: currentPage == PageType.admin,
                      onTap: () {
                        Navigator.pop(context);
                        changePage(PageType.admin);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryTurquoise : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppColors.secondaryBlue : null,
      onTap: onTap,
    );
  }
}
