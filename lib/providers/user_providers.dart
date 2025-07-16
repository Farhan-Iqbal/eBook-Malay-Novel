import 'package:flutter/foundation.dart';

/// A ChangeNotifier that holds the current user's ID.
/// This allows the user ID to be accessed throughout the app
/// via the Provider package.
class UserProvider with ChangeNotifier {
  String? _currentUserId;

  /// Getter for the current user's ID.
  String? get currentUserId => _currentUserId;

  /// Sets the current user's ID and notifies listeners if the ID has changed.
  void setUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      notifyListeners();
    }
  }
}
