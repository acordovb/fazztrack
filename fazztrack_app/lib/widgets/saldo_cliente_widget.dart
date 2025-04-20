import 'package:fazztrack_app/common/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaldoClienteWidget extends StatefulWidget {
  final Function(String)? onClientSelected;
  final double balance;
  final List<String> clients;
  final String initialClient;

  const SaldoClienteWidget({
    super.key,
    this.onClientSelected,
    this.balance = 0.0,
    required this.clients,
    required this.initialClient,
  });

  @override
  State<SaldoClienteWidget> createState() => _SaldoClienteWidgetState();
}

class _SaldoClienteWidgetState extends State<SaldoClienteWidget> {
  late String selectedClient;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> filteredClients = [];

  @override
  void initState() {
    super.initState();
    selectedClient = widget.initialClient;
    filteredClients = widget.clients;
  }

  void _filterClients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredClients = widget.clients;
      } else {
        filteredClients =
            widget.clients
                .where(
                  (client) =>
                      client.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos color basado en el saldo
    final balanceColor =
        widget.balance >= 0 ? AppColors.success : AppColors.error;
    final balanceText = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    ).format(widget.balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                filteredClients = widget.clients;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Botón para mostrar/ocultar buscador
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedClient,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Eliminamos el icono de lupa aquí
                    Icon(
                      _isSearching ? Icons.close : Icons.arrow_drop_down,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearching ? 50 : 0,
                  child:
                      _isSearching
                          ? TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search, color: AppColors.lightGray),
                                prefixIconConstraints: BoxConstraints(minWidth: 40),
                                hintText: "Buscar cliente...",
                                hintStyle: TextStyle(color: AppColors.lightGray),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 15), // Ajustamos el padding vertical
                                isDense: true, // Ayuda a controlar el tamaño del campo
                                alignLabelWithHint: true, // Alinea el hint con el icono
                              ),
                              textAlignVertical: TextAlignVertical.center, // Centra el texto verticalmente
                              style: const TextStyle(color: AppColors.textPrimary),
                              onChanged: _filterClients,
                            )
                          : null,
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearching ? 150 : 0,
                  child:
                      _isSearching
                          ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredClients.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      filteredClients[index],
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedClient = filteredClients[index];
                                        _isSearching = false;
                                        _searchController.clear();
                                      });
                                      if (widget.onClientSelected != null) {
                                        widget.onClientSelected!(selectedClient);
                                      }
                                    },
                                  );
                                },
                              ),
                            )
                          : null,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: balanceColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            balanceText,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Saldo actual',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
