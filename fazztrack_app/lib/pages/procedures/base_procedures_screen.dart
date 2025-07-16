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
  bool _isMenuExpanded = false;
  bool _showMenuContent = false;

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

  void _toggleMenu() async {
    if (_isMenuExpanded) {
      // Si está expandido, primero ocultar contenido, luego colapsar
      setState(() {
        _showMenuContent = false;
      });
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _isMenuExpanded = false;
      });
    } else {
      // Si está colapsado, primero expandir, luego mostrar contenido
      setState(() {
        _isMenuExpanded = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _showMenuContent = true;
      });
    }
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
            // Menú lateral con capacidad de expandir/colapsar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isMenuExpanded ? 280 : 80,
              child: CustomSideMenu(
                changePage: _changePage,
                currentPage: _currentPage,
                isWideScreen: true,
                isExpanded: _isMenuExpanded,
                showContent: _showMenuContent,
                onToggleExpanded: _toggleMenu,
              ),
            ),
            // Divisor vertical
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 0.1,
              color: AppColors.primaryDarkBlue.withAlpha(30),
            ),
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
    required this.isExpanded,
    required this.showContent,
    required this.onToggleExpanded,
  });

  final Function(PageType) changePage;
  final PageType currentPage;
  final bool isWideScreen;
  final bool isExpanded;
  final bool showContent;
  final VoidCallback onToggleExpanded;

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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isExpanded ? 20 : 16,
                        vertical: 10,
                      ),
                      child:
                          widget.isExpanded
                              ? const Divider(
                                color: AppColors.textSecondary,
                                thickness: 0.5,
                              )
                              : Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                color: AppColors.textSecondary.withAlpha(127),
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
            // Botón para expandir/colapsar el menú
            Container(
              margin: const EdgeInsets.all(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onToggleExpanded,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withAlpha(10),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isExpanded
                              ? Icons.keyboard_arrow_left
                              : Icons.keyboard_arrow_right,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        if (widget.isExpanded && widget.showContent) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Colapsar',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
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
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 16 : 8,
              vertical: 12,
            ),
            child:
                widget.isExpanded && widget.showContent
                    ? Row(
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
                            color:
                                isSelected ? Colors.white : AppColors.primary,
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
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
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
                    )
                    : Center(
                      child: Tooltip(
                        message: title,
                        child: Container(
                          width: 48,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primaryTurquoise
                                    : AppColors.primary.withAlpha(10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color:
                                isSelected ? Colors.white : AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
