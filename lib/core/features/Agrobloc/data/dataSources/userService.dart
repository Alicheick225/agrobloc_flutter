import '../models/authentificationModel.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  AuthentificationModel? _currentUser;
  String? _userId;

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  // Getter for current user
  AuthentificationModel? get currentUser => _currentUser;
  
  // Getter for user ID
  String? get userId => _userId;

  // Setter for current user
  void setCurrentUser(AuthentificationModel user) {
    _currentUser = user;
    _userId = user.id;
  }

  // Clear current user (for logout)
  void clearCurrentUser() {
    _currentUser = null;
    _userId = null;
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
}
