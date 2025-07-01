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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive design for better window display
          bool isDesktop = constraints.maxWidth > 800;
          double maxWidth = isDesktop ? 1200 : double.infinity;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.all(20),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel for controls
        Container(
          width: 350,
          child: Column(
            children: [
              _buildStudentSelector(),
              const SizedBox(height: 20),
              if (_selectedEstudiante != null) _buildTransactionTypeSelector(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right panel for transactions list
        Expanded(
          child:
              _selectedEstudiante != null
                  ? _buildTransactionsList()
                  : Container(
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
                    child: const Center(
                      child: Text(
                        'Seleccione un estudiante para ver las transacciones',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildStudentAutocomplete(),
        ],
      ),
    );
  }

  Widget _buildStudentAutocomplete() {
    return Autocomplete<EstudianteModel>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _estudiantes;
        }
        return _estudiantes.where((EstudianteModel estudiante) {
          return estudiante.nombre.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      displayStringForOption: (EstudianteModel option) => option.nombre,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Buscar y seleccionar estudiante...',
            hintStyle: TextStyle(color: AppColors.textPrimary.withAlpha(70)),
            prefixIcon: Icon(Icons.search, color: AppColors.primaryTurquoise),
            suffixIcon:
                textEditingController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textPrimary.withAlpha(70),
                      ),
                      onPressed: () {
                        textEditingController.clear();
                        setState(() {
                          _selectedEstudiante = null;
                          _ventas = [];
                          _abonos = [];
                        });
                      },
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: AppColors.backgroundSecondary,
            filled: true,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          onSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<EstudianteModel> onSelected,
        Iterable<EstudianteModel> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: AppColors.backgroundSecondary,
            elevation: 8.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width:
                  MediaQuery.of(context).size.width -
                  72, // Adjust width as needed
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final EstudianteModel option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.lightBlue.withAlpha(20),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: AppColors.primaryTurquoise,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.nombre,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (option.curso != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Curso: ${option.curso}',
                                    style: TextStyle(
                                      color: AppColors.textPrimary.withAlpha(
                                        70,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (EstudianteModel selection) {
        setState(() {
          _selectedEstudiante = selection;
          _ventas = [];
          _abonos = [];
        });
        _loadTransactions();
      },
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  text: 'Ventas',
                  icon: Icons.shopping_cart,
                  isSelected: _selectedTransactionType == 'ventas',
                  onPressed: () {
                    setState(() => _selectedTransactionType = 'ventas');
                    _loadTransactions();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleButton(
                  text: 'Abonos',
                  icon: Icons.payments,
                  isSelected: _selectedTransactionType == 'abonos',
                  onPressed: () {
                    setState(() => _selectedTransactionType = 'abonos');
                    _loadTransactions();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected
                  ? AppColors.primaryTurquoise
                  : AppColors.backgroundSecondary,
          foregroundColor:
              isSelected ? AppColors.primaryDarkBlue : AppColors.textPrimary,
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color:
                  isSelected ? AppColors.primaryTurquoise : AppColors.lightBlue,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTurquoise.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: AppColors.primaryTurquoise,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Producto: ${venta.producto?.nombre ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryTurquoise,
                      ),
                      onPressed: () => _editVenta(venta),
                      tooltip: 'Editar venta',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _deleteVenta(venta),
                      tooltip: 'Eliminar venta',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.inventory_2,
                    'Cantidad',
                    '${venta.nProductos}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.access_time,
                    'Fecha',
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(venta.fechaTransaccion),
                  ),
                ),
              ],
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payments,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Total: \$${abono.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryTurquoise,
                      ),
                      onPressed: () => _editAbono(abono),
                      tooltip: 'Editar abono',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _deleteAbono(abono),
                      tooltip: 'Eliminar abono',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.category,
                    'Tipo',
                    abono.tipoAbono,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.access_time,
                    'Fecha',
                    DateFormat('dd/MM/yyyy HH:mm').format(abono.fechaAbono),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBlue.withAlpha(30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryTurquoise),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary.withAlpha(70),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  @override
  void initState() {
    super.initState();
    _nProductosController = TextEditingController(
      text: widget.venta.nProductos.toString(),
    );
  }

  @override
  void dispose() {
    _nProductosController.dispose();
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
          // Mostrar información del producto (solo lectura)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.lightBlue.withAlpha(30),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: AppColors.primaryTurquoise,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Producto: ${widget.venta.producto?.nombre ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nProductosController,
            decoration: const InputDecoration(
              labelText: 'Cantidad de productos',
              labelStyle: TextStyle(color: AppColors.textPrimary),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.number,
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
            final cantidad = int.tryParse(_nProductosController.text);
            if (cantidad == null || cantidad <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor ingrese una cantidad válida'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final updatedVenta = VentaModel(
              id: widget.venta.id,
              idEstudiante: widget.venta.idEstudiante,
              idProducto: widget.venta.idProducto,
              fechaTransaccion: widget.venta.fechaTransaccion,
              idBar: widget.venta.idBar,
              nProductos: cantidad,
              total: widget.venta.total,
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
  late String _selectedTipoAbono;

  final List<String> _tiposAbono = ['Transferencia', 'Efectivo'];

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(
      text: widget.abono.total.toString(),
    );
    // Verificar si el tipo de abono actual está en la lista, si no, usar el primero
    _selectedTipoAbono =
        _tiposAbono.contains(widget.abono.tipoAbono)
            ? widget.abono.tipoAbono
            : _tiposAbono.first;
  }

  @override
  void dispose() {
    _totalController.dispose();
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
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTipoAbono,
            decoration: const InputDecoration(
              labelText: 'Tipo de Abono',
              labelStyle: TextStyle(color: AppColors.textPrimary),
              border: OutlineInputBorder(),
            ),
            dropdownColor: AppColors.backgroundSecondary,
            style: const TextStyle(color: AppColors.textPrimary),
            items:
                _tiposAbono.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Row(
                      children: [
                        Icon(
                          tipo == 'Transferencia'
                              ? Icons.account_balance
                              : Icons.payments,
                          color: AppColors.primaryTurquoise,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tipo,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTipoAbono = newValue;
                });
              }
            },
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
            final total = double.tryParse(_totalController.text);
            if (total == null || total <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor ingrese un monto válido'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final updatedAbono = AbonoModel(
              id: widget.abono.id,
              idEstudiante: widget.abono.idEstudiante,
              total: total,
              tipoAbono: _selectedTipoAbono,
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
