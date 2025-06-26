import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class AbonoProvider {
  final ApiService _apiService = ApiService();

  Future<String> registrarAbono(
    EstudianteModel estudiante,
    AbonoModel abono,
    ControlHistoricoModel controlHistorico,
  ) async {
    final newControlHistorico = controlHistorico.copyWith(
      totalAbono: controlHistorico.totalAbono + abono.total,
    );

    final body = {
      'abono': abono.toJson(),
      'controlHistorico': newControlHistorico.toJson(),
    };
    try {
      await _apiService.post('/abonos', body);
      return 'OK';
    } catch (e) {
      if (e.toString().contains('HTTP error: 404')) {
        return 'Error: No se encontró el recurso';
      } else if (e.toString().contains('HTTP error: 500')) {
        return 'Error: Error interno del servidor';
      } else {
        return 'Error: ${e.toString()}';
      }
    }
  }
}
