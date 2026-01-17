abstract class BaseModel {
  const BaseModel();
  
  /// Convert model to JSON
  Map<String, dynamic> toJson();
  
  /// Create model from JSON
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in the child class');
  }
}
