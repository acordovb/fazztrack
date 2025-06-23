import 'package:flutter/material.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';

class EstudianteCard extends StatelessWidget {
  final EstudianteModel estudiante;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EstudianteCard({
    super.key,
    required this.estudiante,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryTurquoise,
                  radius: 24,
                  child: Text(
                    estudiante.nombre.isNotEmpty
                        ? estudiante.nombre[0].toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: AppColors.primaryDarkBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estudiante.nombre,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (estudiante.curso != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Curso: ${estudiante.curso}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (estudiante.celular != null ||
                estudiante.nombreRepresentante != null) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.primaryTurquoise, height: 1),
              const SizedBox(height: 12),
            ],
            if (estudiante.celular != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: AppColors.primaryTurquoise,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    estudiante.celular!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (estudiante.nombreRepresentante != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: AppColors.primaryTurquoise,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Representante: ${estudiante.nombreRepresentante}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null) ...[
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryTurquoise,
                        size: 20,
                      ),
                      tooltip: 'Editar',
                    ),
                  ],
                  if (onDelete != null) ...[
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.error,
                        size: 20,
                      ),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
