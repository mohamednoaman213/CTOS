class AppSession {
  static final AppSession instance = AppSession._();
  AppSession._();

  String name = '';
  String email = '';
  String role = 'citizen';
  int userId = 0;
  int reportCount = 0;
  int resolvedCount = 0;
  bool notificationsEnabled = true;

  void clear() {
    name = '';
    email = '';
    role = 'citizen';
    userId = 0;
    reportCount = 0;
    resolvedCount = 0;
    notificationsEnabled = true;
  }
}
