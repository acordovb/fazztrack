import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/services/bar/bar_api_service.dart';
import 'package:flutter/material.dart';

class CreateBarDialog extends StatefulWidget {
  final VoidCallback? onBarCreated;

  const CreateBarDialog({super.key, this.onBarCreated});

  @override
  State<CreateBarDialog> createState() => _CreateBarDialogState();
}

class _CreateBarDialogState extends State<CreateBarDialog> {
  final BarApiService _barService = BarApiService();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createBar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isCreating) {
      return; // Prevenir múltiples envíos
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await _barService.createBar(_nameController.text.trim());

      // Cerrar el diálogo
      if (mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Ejecutar callback para recargar la lista
        widget.onBarCreated?.call();
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear local: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Center(
        child: Icon(
          Icons.store_mall_directory,
          color: AppColors.primaryTurquoise,
          size: 32,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre del Local *',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  hintText: 'Ingresa el nombre del local',
                  hintStyle: const TextStyle(color: AppColors.textPrimary),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryTurquoise,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del local es requerido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createBar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTurquoise,
            foregroundColor: AppColors.primaryDarkBlue,
          ),
          child:
              _isCreating
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryDarkBlue,
                      ),
                    ),
                  )
                  : const Text('Crear'),
        ),
      ],
    );
  }
}
