import 'package:fazztrack_app/config/build.config.dart';
import 'package:fazztrack_app/config/general.config.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/pages/admin/admin_screen.dart';
import 'package:fazztrack_app/pages/procedures/abono_screen.dart';
import 'package:fazztrack_app/pages/procedures/consumo_screen.dart';
import 'package:fazztrack_app/pages/reports/reports_screen.dart';
import 'package:flutter/material.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen =
        screenWidth > 768; // Punto de quiebre para tablet/desktop

    if (isWideScreen) {
      // Layout para pantallas grandes (tablet/desktop)
      return Scaffold(
        body: Row(
          children: [
            // Menú lateral permanente
            SizedBox(
              width: 280,
              child: CustomSideMenu(
                changePage: _changePage,
                currentPage: _currentPage,
                isWideScreen: true,
              ),
            ),
            // Divisor vertical
            Container(width: 1, color: AppColors.textSecondary.withAlpha(20)),
            // Contenido principal con su propio AppBar
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.backgroundSecondary,
                  title: Text(
                    _pageTitles[_currentPage] ?? widget.title,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  automaticallyImplyLeading: false, // No mostrar botón de menú
                ),
                body: _getCurrentPageContent(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Layout para pantallas pequeñas (móvil)
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
        drawer: CustomDrawer(
          changePage: _changePage,
          currentPage: _currentPage,
        ),
        body: _getCurrentPageContent(),
      );
    }
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
    required this.changePage,
    required this.currentPage,
  });

  final Function(PageType) changePage;
  final PageType currentPage;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isNavigating = false;

  void _handlePageChange(PageType page) async {
    // Prevenir múltiples navegaciones simultáneas
    if (_isNavigating) return;

    // No hacer nada si ya estamos en la página seleccionada
    if (widget.currentPage == page) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    // Cerrar el drawer si está abierto
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Esperar un momento para que se complete la animación del drawer
    await Future.delayed(const Duration(milliseconds: 100));

    // Cambiar la página
    widget.changePage(page);

    // Resetear el flag después de un momento
    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _buildDrawerItem(
                context: context,
                title: 'Reportar Consumo',
                subtitle: 'Registrar ventas y transacciones',
                icon: Icons.point_of_sale_rounded,
                isSelected: widget.currentPage == PageType.consumo,
                onTap: () => _handlePageChange(PageType.consumo),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Reportar Abono',
                subtitle: 'Gestionar pagos y abonos',
                icon: Icons.account_balance_wallet_rounded,
                isSelected: widget.currentPage == PageType.abono,
                onTap: () => _handlePageChange(PageType.abono),
              ),
              if (BuildConfig.appLevel == AppConfig.appLevel.admin) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Divider(
                    color: AppColors.textSecondary,
                    thickness: 0.5,
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  title: 'Administración',
                  subtitle: 'Configuración del sistema',
                  icon: Icons.admin_panel_settings_rounded,
                  isSelected: widget.currentPage == PageType.admin,
                  onTap: () => _handlePageChange(PageType.admin),
                ),
                _buildDrawerItem(
                  context: context,
                  title: 'Reportes',
                  subtitle: 'Análisis y estadísticas',
                  icon: Icons.bar_chart_rounded,
                  isSelected: widget.currentPage == PageType.reports,
                  onTap: () => _handlePageChange(PageType.reports),
                ),
              ],
            ],
          ),
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
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
            isSelected
                ? AppColors.primaryTurquoise.withAlpha(15)
                : Colors.transparent,
        border:
            isSelected
                ? Border.all(
                  color: AppColors.primaryTurquoise.withAlpha(30),
                  width: 1,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primaryTurquoise
                            : AppColors.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppColors.primaryTurquoise
                                  : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTurquoise,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSideMenu extends StatefulWidget {
  const CustomSideMenu({
    super.key,
    required this.changePage,
    required this.currentPage,
    required this.isWideScreen,
  });

  final Function(PageType) changePage;
  final PageType currentPage;
  final bool isWideScreen;

  @override
  State<CustomSideMenu> createState() => _CustomSideMenuState();
}

class _CustomSideMenuState extends State<CustomSideMenu> {
  void _handlePageChange(PageType page) {
    // No hacer nada si ya estamos en la página seleccionada
    if (widget.currentPage == page) return;

    // Cambiar la página directamente (sin cerrar drawer)
    widget.changePage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildSideMenuItem(
                    context: context,
                    title: 'Reportar Consumo',
                    subtitle: 'Registrar ventas y transacciones',
                    icon: Icons.point_of_sale_rounded,
                    isSelected: widget.currentPage == PageType.consumo,
                    onTap: () => _handlePageChange(PageType.consumo),
                  ),
                  _buildSideMenuItem(
                    context: context,
                    title: 'Reportar Abono',
                    subtitle: 'Gestionar pagos y abonos',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: widget.currentPage == PageType.abono,
                    onTap: () => _handlePageChange(PageType.abono),
                  ),
                  if (BuildConfig.appLevel == AppConfig.appLevel.admin) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Divider(
                        color: AppColors.textSecondary,
                        thickness: 0.5,
                      ),
                    ),
                    _buildSideMenuItem(
                      context: context,
                      title: 'Administración',
                      subtitle: 'Configuración del sistema',
                      icon: Icons.admin_panel_settings_rounded,
                      isSelected: widget.currentPage == PageType.admin,
                      onTap: () => _handlePageChange(PageType.admin),
                    ),
                    _buildSideMenuItem(
                      context: context,
                      title: 'Reportes',
                      subtitle: 'Análisis y estadísticas',
                      icon: Icons.bar_chart_rounded,
                      isSelected: widget.currentPage == PageType.reports,
                      onTap: () => _handlePageChange(PageType.reports),
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

  Widget _buildSideMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
            isSelected
                ? AppColors.primaryTurquoise.withAlpha(15)
                : Colors.transparent,
        border:
            isSelected
                ? Border.all(
                  color: AppColors.primaryTurquoise.withAlpha(30),
                  width: 1,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primaryTurquoise
                            : AppColors.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppColors.primaryTurquoise
                                  : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTurquoise,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
