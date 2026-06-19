class ApiConstants {
  // Inject via: flutter run --dart-define=BASE_URL=https://api.example.com
  // Defaults to Android emulator address for local development.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://kitsandkids-api.onrender.com',
  );

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Users
  static const String profile = '/users/profile';

  // Products
  static const String products = '/products';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/mine';
}
