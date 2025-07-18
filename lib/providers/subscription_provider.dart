import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _hasSubscription = false;
  DateTime? _subscriptionExpiry;

  bool get hasSubscription => _hasSubscription;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;

  bool get isSubscriptionActive {
    return _hasSubscription &&
        _subscriptionExpiry != null &&
        _subscriptionExpiry!.isAfter(DateTime.now());
  }

  // Load subscription status from SharedPreferences
  Future<void> loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSubscription = prefs.getBool('has_subscription') ?? false;
    final expiryString = prefs.getString('subscription_expiry');
    _subscriptionExpiry =
        expiryString != null ? DateTime.parse(expiryString) : null;
    notifyListeners();
  }

  // Set subscription status and expiry, then save to SharedPreferences
  Future<void> setSubscription({
    required bool status,
    DateTime? expiry,
  }) async {
    _hasSubscription = status;
    _subscriptionExpiry = expiry;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_subscription', status);
    if (expiry != null) {
      await prefs.setString('subscription_expiry', expiry.toIso8601String());
    } else {
      await prefs.remove('subscription_expiry');
    }
    notifyListeners();
  }

  void clearSubscription() {
    _hasSubscription = false;
    _subscriptionExpiry = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('has_subscription');
      prefs.remove('subscription_expiry');
    });
    notifyListeners();
  }
}