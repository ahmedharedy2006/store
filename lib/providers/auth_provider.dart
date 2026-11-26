// ============================================================================
// Provider: AuthProvider
// Purpose: Manages user Authentication state (Register, Login, Logout)
// State Management: Flutter Provider (ChangeNotifier)
// Storage: Hive database ('users_box')
// ============================================================================

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class AuthProvider extends ChangeNotifier {
  // Store the currently logged-in user (null if not logged in)
  UserModel? _currentUser;

  // Loading state indicator for showing progress indicator in UI
  bool _isLoading = false;

  // Holds any error message to display in snackbars or alert boxes
  String? _errorMessage;

  // --------------------------------------------------------------------------
  // Getters to expose state properties safely to UI widgets
  // --------------------------------------------------------------------------
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --------------------------------------------------------------------------
  // 1. REGISTER OPERATION (Saves new user into Hive Box)
  // --------------------------------------------------------------------------
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Start loading spinner
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Access the users Hive box
      final Box usersBox = HiveService.getUsersBox();

      // Normalize email (lowercase and trimmed)
      final cleanEmail = email.trim().toLowerCase();

      // Check if user already exists in Hive
      if (usersBox.containsKey(cleanEmail)) {
        _errorMessage = 'An account with this email already exists!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user model instance
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: cleanEmail,
        password: password,
      );

      // Save user to Hive box: Key = cleanEmail, Value = user Map
      await usersBox.put(cleanEmail, newUser.toMap());

      // Set logged-in user
      _currentUser = newUser;
      _isLoading = false;
      _errorMessage = null;

      // Notify listening UI widgets to update
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // 2. LOGIN OPERATION (Retrieves and verifies user from Hive Box)
  // --------------------------------------------------------------------------
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Start loading indicator
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Access the users Hive box
      final Box usersBox = HiveService.getUsersBox();

      // Normalize email (lowercase and trimmed)
      final cleanEmail = email.trim().toLowerCase();

      // Check if user exists in the box
      if (!usersBox.containsKey(cleanEmail)) {
        _errorMessage = 'No account found with this email!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Retrieve user raw Map data from Hive
      final dynamic rawData = usersBox.get(cleanEmail);

      // Convert retrieved Map back to UserModel
      if (rawData is Map) {
        final user = UserModel.fromMap(rawData);

        // Verify password
        if (user.password == password) {
          _currentUser = user;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Incorrect password! Please try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Corrupted user data in local database.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // 3. LOGOUT OPERATION (Clears current session)
  // --------------------------------------------------------------------------
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    // Notify all UI listeners that user has logged out
    notifyListeners();
  }
}
