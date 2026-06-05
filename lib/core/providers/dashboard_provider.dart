import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  // Trạng thái cho Dropdown chọn Nông sản (biểu đồ giá)
  String _selectedCrop = 'Coffee'; 
  String get selectedCrop => _selectedCrop;

  // Trạng thái cho Dropdown chọn Vườn (thông tin field)
  String _selectedFieldId = 'primary_field';
  String get selectedFieldId => _selectedFieldId;

  // Cập nhật loại nông sản và render lại UI biểu đồ
  void setSelectedCrop(String crop) {
    if (_selectedCrop != crop) {
      _selectedCrop = crop;
      notifyListeners();
    }
  }

  // Cập nhật khu vực vườn và render lại thông tin vườn
  void setSelectedField(String fieldId) {
    if (_selectedFieldId != fieldId) {
      _selectedFieldId = fieldId;
      notifyListeners();
    }
  }
}