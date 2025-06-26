import 'package:flutter/material.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';

class BuscadorReporte extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  const BuscadorReporte({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onClear,
    this.onChanged,
  });

  @override
  State<BuscadorReporte> createState() => _BuscadorReporteState();
}

class _BuscadorReporteState extends State<BuscadorReporte> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clearSearch() {
    widget.controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTurquoise.withOpacity(0.3)),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.6)),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryTurquoise,
          ),
          suffixIcon:
              widget.controller.text.isNotEmpty
                  ? IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                    tooltip: 'Limpiar búsqueda',
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
