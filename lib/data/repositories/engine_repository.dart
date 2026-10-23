
import '../models/engine_data.dart';

class EngineRepository {
  EngineData _currentData = EngineData.initial();

  EngineData get currentData => _currentData;

  void updateData(EngineData newData) {
    _currentData = newData;
  }

  void resetData() {
    _currentData = EngineData.initial();
  }
}
