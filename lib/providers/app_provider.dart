import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {

  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _isOnboardingComplete = await StorageService.instance.getOnboardingStatus();

    _isInitialized = true;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    await StorageService.instance.setOnboardingStatus(true);

    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _isOnboardingComplete = false;
    await StorageService.instance.setOnboardingStatus(false);

    notifyListeners();
  }
}