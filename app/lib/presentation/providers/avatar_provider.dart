import 'package:flutter/material.dart';
import '../../models/avatar_config.dart';

class AvatarProvider extends ChangeNotifier {
  AvatarConfig _config = AvatarConfig.defaultConfig();
  bool _ready = false;

  AvatarConfig get config => _config;
  bool get ready => _ready;

  void load() {
    // Simulate loading from storage or backend
    _ready = true;
    notifyListeners();
  }

  void updateConfig(AvatarConfig config) {
    _config = config;
    notifyListeners();
  }
}
