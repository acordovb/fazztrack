import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/venta_model.dart';
import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:fazztrack_app/services/ventas/ventas_api_service.dart';
import 'package:fazztrack_app/services/abonos/abono_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionAdminScreen extends StatefulWidget {
  const TransactionAdminScreen({super.key});

  @override
  State<TransactionAdminScreen> createState() => _TransactionAdminScreenState();
}

class _TransactionAdminScreenState extends State<TransactionAdminScreen> {
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final VentasApiService _ventasService = VentasApiService();
  final AbonoApiService _abonoService = AbonoApiService();

  List<EstudianteModel> _estudiantes = [];
  EstudianteModel? _selectedEstudiante;
  String _selectedTransactionType = 'ventas'; // 'ventas' or 'abonos'
  List<VentaModel> _ventas = [];
  List<AbonoModel> _abonos = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadEstudiantes();
  }

  Future<void> _loadEstudiantes() async {
    setState(() => _isLoading = true);
    try {
      final estudiantes = await _estudiantesService.getAllEstudiantes();
      setState(() {
        _estudiantes = estudiantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar estudiantes: $e');
    }
  }

  Future<void> _loadTransactions() async {
    if (_selectedEstudiante == null) return;

    setState(() => _isLoadingTransactions = true);
    try {
      if (_selectedTransactionType == 'ventas') {
        final ventas = await _ventasService.findAllByStudent(
          _selectedEstudiante!.id,
        );
        setState(() {
          _ventas = ventas;
          _abonos = [];
        });
      } else {
        final abonos = await _abonoService.findAllByStudent(
          _selectedEstudiante!.id,
        );
        setState(() {
          _abonos = abonos;
          _ventas = [];
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar transacciones: $e');
    } finally {
      setState(() => _isLoadingTransactions = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gestión de Transacciones',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundSecondary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentSelector(),
            const SizedBox(height: 20),
            if (_selectedEstudiante != null) ...[
              _buildTransactionTypeSelector(),
              const SizedBox(height: 20),
              _buildTransactionsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionar Estudiante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<EstudianteModel>(
                value: _selectedEstudiante,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: AppColors.backgroundSecondary,
                  filled: true,
                ),
                dropdownColor: AppColors.backgroundSecondary,
                style: const TextStyle(color: AppColors.textPrimary),
                hint: const Text(
                  'Seleccione un estudiante',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                items:
                    _estudiantes.map((estudiante) {
                      return DropdownMenuItem<EstudianteModel>(
                        value: estudiante,
                        child: Text(
                          estudiante.nombre,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                onChanged: (EstudianteModel? newValue) {
                  setState(() {
                    _selectedEstudiante = newValue;
                    _ventas = [];
                    _abonos = [];
                  });
                  if (newValue != null) {
                    _loadTransactions();
                  }
                },
              ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Transacción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    'Ventas',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  value: 'ventas',
                  groupValue: _selectedTransactionType,
                  activeColor: AppColors.primaryTurquoise,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _selectedTransactionType = value);
                      _loadTransactions();
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    'Abonos',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  value: 'abonos',
                  groupValue: _selectedTransactionType,
                  activeColor: AppColors.primaryTurquoise,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _selectedTransactionType = value);
                      _loadTransactions();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedTransactionType == 'ventas' ? 'Ventas' : 'Abonos',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _isLoadingTransactions
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedTransactionType == 'ventas'
                      ? _buildVentasList()
                      : _buildAbonosList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentasList() {
    if (_ventas.isEmpty) {
      return const Center(
        child: Text(
          'No hay ventas registradas',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      );
    }

    return ListView.builder(
      itemCount: _ventas.length,
      itemBuilder: (context, index) {
        final venta = _ventas[index];
        return _buildVentaCard(venta);
      },
    );
  }

  Widget _buildAbonosList() {
    if (_abonos.isEmpty) {
      return const Center(
        child: Text(
          'No hay abonos registrados',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      );
    }

    return ListView.builder(
      itemCount: _abonos.length,
      itemBuilder: (context, index) {
        final abono = _abonos[index];
        return _buildAbonoCard(abono);
      },
    );
  }

  Widget _buildVentaCard(VentaModel venta) {
    return Card(
      color: AppColors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          'Producto: ${venta.producto?.nombre ?? 'N/A'}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cantidad: ${venta.nProductos}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            Text(
              'Fecha: ${venta.fechaTransaccion != null ? DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaTransaccion!) : 'N/A'}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            Text(
              'Bar: ${venta.idBar}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryTurquoise),
              onPressed: () => _editVenta(venta),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _deleteVenta(venta),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbonoCard(AbonoModel abono) {
    return Card(
      color: AppColors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          'Total: \$${abono.total.toStringAsFixed(2)}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo: ${abono.tipoAbono}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            Text(
              'Fecha: ${abono.fechaAbono != null ? DateFormat('dd/MM/yyyy HH:mm').format(abono.fechaAbono!) : 'N/A'}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryTurquoise),
              onPressed: () => _editAbono(abono),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _deleteAbono(abono),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editVenta(VentaModel venta) async {
    final result = await showDialog<VentaModel>(
      context: context,
      builder: (context) => _EditVentaDialog(venta: venta),
    );

    if (result != null) {
      try {
        await _ventasService.updateVenta(venta.id!, result);
        _showSuccessSnackBar('Venta actualizada correctamente');
        _loadTransactions();
      } catch (e) {
        _showErrorSnackBar('Error al actualizar venta: $e');
      }
    }
  }

  Future<void> _editAbono(AbonoModel abono) async {
    final result = await showDialog<AbonoModel>(
      context: context,
      builder: (context) => _EditAbonoDialog(abono: abono),
    );

    if (result != null) {
      try {
        await _abonoService.updateAbono(abono.id!, result);
        _showSuccessSnackBar('Abono actualizado correctamente');
        _loadTransactions();
      } catch (e) {
        _showErrorSnackBar('Error al actualizar abono: $e');
      }
    }
  }

  Future<void> _deleteVenta(VentaModel venta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text(
              'Confirmar eliminación',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              '¿Está seguro de que desea eliminar esta venta?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _ventasService.deleteVenta(venta.id!);
        _showSuccessSnackBar('Venta eliminada correctamente');
        _loadTransactions();
      } catch (e) {
        _showErrorSnackBar('Error al eliminar venta: $e');
      }
    }
  }

  Future<void> _deleteAbono(AbonoModel abono) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text(
              'Confirmar eliminación',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              '¿Está seguro de que desea eliminar este abono?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _abonoService.deleteAbono(abono.id!);
        _showSuccessSnackBar('Abono eliminado correctamente');
        _loadTransactions();
      } catch (e) {
        _showErrorSnackBar('Error al eliminar abono: $e');
      }
    }
  }
}

class _EditVentaDialog extends StatefulWidget {
  final VentaModel venta;

  const _EditVentaDialog({required this.venta});

  @override
  State<_EditVentaDialog> createState() => _EditVentaDialogState();
}

class _EditVentaDialogState extends State<_EditVentaDialog> {
  late TextEditingController _nProductosController;
  late TextEditingController _idBarController;

  @override
  void initState() {
    super.initState();
    _nProductosController = TextEditingController(
      text: widget.venta.nProductos.toString(),
    );
    _idBarController = TextEditingController(text: widget.venta.idBar);
  }

  @override
  void dispose() {
    _nProductosController.dispose();
    _idBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text(
        'Editar Venta',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nProductosController,
            decoration: const InputDecoration(
              labelText: 'Cantidad de productos',
              labelStyle: TextStyle(color: AppColors.textPrimary),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _idBarController,
            decoration: const InputDecoration(
              labelText: 'ID del Bar',
              labelStyle: TextStyle(color: AppColors.textPrimary),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedVenta = VentaModel(
              id: widget.venta.id,
              idEstudiante: widget.venta.idEstudiante,
              idProducto: widget.venta.idProducto,
              fechaTransaccion: widget.venta.fechaTransaccion,
              idBar: _idBarController.text,
              nProductos:
                  int.tryParse(_nProductosController.text) ??
                  widget.venta.nProductos,
              producto: widget.venta.producto,
            );
            Navigator.of(context).pop(updatedVenta);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _EditAbonoDialog extends StatefulWidget {
  final AbonoModel abono;

  const _EditAbonoDialog({required this.abono});

  @override
  State<_EditAbonoDialog> createState() => _EditAbonoDialogState();
}

class _EditAbonoDialogState extends State<_EditAbonoDialog> {
  late TextEditingController _totalController;
  late TextEditingController _tipoAbonoController;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(
      text: widget.abono.total.toString(),
    );
    _tipoAbonoController = TextEditingController(text: widget.abono.tipoAbono);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _tipoAbonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text(
        'Editar Abono',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _totalController,
            decoration: const InputDecoration(
              labelText: 'Total',
              labelStyle: TextStyle(color: AppColors.textPrimary),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tipoAbonoController,
            decoration: const InputDecoration(
              labelText: 'Tipo de Abono',
              labelStyle: TextStyle(color: AppColors.textPrimary),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedAbono = AbonoModel(
              id: widget.abono.id,
              idEstudiante: widget.abono.idEstudiante,
              total:
                  double.tryParse(_totalController.text) ?? widget.abono.total,
              tipoAbono: _tipoAbonoController.text,
              fechaAbono: widget.abono.fechaAbono,
            );
            Navigator.of(context).pop(updatedAbono);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
