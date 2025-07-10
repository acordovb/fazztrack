class ReportResponseModel {
  final String message;

  ReportResponseModel({required this.message});

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) {
    return ReportResponseModel(message: json['message'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
