class AppSession {
  static final AppSession instance = AppSession._();
  AppSession._();

  String name = '';
  String email = '';
  String role = 'citizen';
  int userId = 0;

  void clear() {
    name = '';
    email = '';
    role = 'citizen';
    userId = 0;
  }
}
