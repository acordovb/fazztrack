export interface ReportData {
  student: {
    id: string;
    nombre: string;
    curso?: string | null;
    celular?: string | null;
    nombre_representante?: string | null;
  };
  abonos: Array<{
    fecha_abono: Date;
    tipo_abono: string;
    comentario?: string;
    total: number;
  }>;
  ventas: Array<{
    fecha_transaccion: Date;
    producto?: { nombre: string };
    n_productos: number;
    total: number;
  }>;
  totalAbonos: number;
  totalVentas: number;
  saldoActual: number;
  saldoPendienteMesAnterior: number;
  currentMonth: number;
}

export interface ProcessedReportData extends ReportData {
  currentMonthName: string;
  currentYear: number;
  currentDate: string;
  currentTime: string;
}
