import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:flutter/material.dart';

class EditEstudianteDialog extends StatefulWidget {
  final EstudianteModel estudiante;
  final VoidCallback? onEstudianteUpdated;
  final List<BarModel> bars;

  const EditEstudianteDialog({
    super.key,
    required this.estudiante,
    this.onEstudianteUpdated,
    required this.bars,
  });

  @override
  State<EditEstudianteDialog> createState() => _EditEstudianteDialogState();
}

class _EditEstudianteDialogState extends State<EditEstudianteDialog> {
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _representanteController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;
  String? _selectedBarId;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form with existing data
    _nombreController.text = widget.estudiante.nombre;
    _celularController.text = widget.estudiante.celular ?? '';
    _cursoController.text = widget.estudiante.curso ?? '';
    _representanteController.text = widget.estudiante.nombreRepresentante ?? '';
    _selectedBarId = widget.estudiante.idBar;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _celularController.dispose();
    _cursoController.dispose();
    _representanteController.dispose();
    super.dispose();
  }

  Future<void> _updateEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isUpdating) {
      return; // Prevenir múltiples envíos
    }

    if (_selectedBarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un bar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final estudianteActualizado = EstudianteModel(
        id: widget.estudiante.id,
        nombre: _nombreController.text.trim(),
        idBar: _selectedBarId!, // Agregamos el bar seleccionado
        celular:
            _celularController.text.trim().isEmpty
                ? null
                : _celularController.text.trim(),
        curso:
            _cursoController.text.trim().isEmpty
                ? null
                : _cursoController.text.trim(),
        nombreRepresentante:
            _representanteController.text.trim().isEmpty
                ? null
                : _representanteController.text.trim(),
      );

      await _estudiantesService.updateEstudiante(
        widget.estudiante.id,
        estudianteActualizado,
      );

      // Cerrar el diálogo
      if (mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estudiante actualizado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );

        // Ejecutar callback para recargar la lista
        widget.onEstudianteUpdated?.call();
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estudiante: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Center(
        child: Icon(Icons.edit, color: AppColors.primaryTurquoise, size: 32),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
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
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown para seleccionar el bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textPrimary, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  dropdownColor: AppColors.backgroundSecondary,
                  value: _selectedBarId,
                  decoration: const InputDecoration(
                    labelText: 'Bar *',
                    labelStyle: TextStyle(color: AppColors.textPrimary),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items:
                      widget.bars.map((bar) {
                        return DropdownMenuItem<String>(
                          value: bar.id,
                          child: Text(bar.nombre),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBarId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor selecciona un bar';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _celularController,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cursoController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Curso',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _representanteController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre del Representante',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
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
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateEstudiante,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTurquoise,
            foregroundColor: AppColors.primaryDarkBlue,
          ),
          child:
              _isUpdating
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
                  : const Text('Actualizar'),
        ),
      ],
    );
  }
}
