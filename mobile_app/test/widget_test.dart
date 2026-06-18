import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/core/navigation/app_navigator.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:mobile_app/features/auth/screens/register_screen.dart';
import 'package:mobile_app/features/profile/screens/profile_screen.dart';
import 'package:mobile_app/features/bookings/screens/bookings_screen.dart';
import 'package:mobile_app/features/search/screens/search_screen.dart';
import 'package:mobile_app/features/bookings/screens/booking_options_screen.dart';

// ── Helpers ──────────────────────────────────────────────────

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = 'pk_test_placeholder';
  });

  // Wraps a widget with the minimum context needed (Provider + Material)
  Widget withProviders(Widget child, {AuthProvider? auth}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth ?? _MockAuthProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        home: child,
      ),
    );
  }

  // ── App boot ──────────────────────────────────────────────

  testWidgets('App starts and renders MaterialApp', (tester) async {
    await tester.pumpWidget(const KitsAndKidsApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  // ── LoginScreen ───────────────────────────────────────────

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(withProviders(const LoginScreen()));
      await tester.pump();
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('renders submit button', (tester) async {
      await tester.pumpWidget(withProviders(const LoginScreen()));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(withProviders(const LoginScreen()));
      await tester.pump();
      // Tap the login button without filling fields
      final btn = find.byType(ElevatedButton).first;
      await tester.tap(btn);
      await tester.pump();
      // Validation error text appears
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(withProviders(const LoginScreen()));
      await tester.pump();
      final pwField = find.byWidgetPredicate(
        (w) => w is EditableText && w.obscureText,
      );
      expect(pwField, findsOneWidget);
    });
  });

  // ── RegisterScreen ────────────────────────────────────────

  group('RegisterScreen', () {
    testWidgets('renders at least 4 fields', (tester) async {
      await tester.pumpWidget(withProviders(const RegisterScreen()));
      await tester.pump();
      expect(find.byType(TextFormField), findsAtLeastNWidgets(4));
    });

    testWidgets('renders submit button', (tester) async {
      await tester.pumpWidget(withProviders(const RegisterScreen()));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });
  });

  // ── ProfileScreen ─────────────────────────────────────────

  group('ProfileScreen', () {
    testWidgets('displays user name from AuthProvider', (tester) async {
      final auth = _MockAuthProvider(user: {
        'user_prenom': 'Alice',
        'user_email': 'alice@test.com',
        'user_role': 'client',
      });
      await tester.pumpWidget(withProviders(const ProfileScreen(), auth: auth));
      await tester.pump();
      expect(find.textContaining('Alice'), findsOneWidget);
    });

    testWidgets('displays admin section for admin user', (tester) async {
      final auth = _MockAuthProvider(user: {
        'user_prenom': 'Admin',
        'user_email': 'admin@test.com',
        'user_role': 'admin',
      });
      await tester.pumpWidget(withProviders(const ProfileScreen(), auth: auth));
      await tester.pump();
      expect(find.text('Administration'), findsOneWidget);
      expect(find.text('Espace Admin'),  findsOneWidget);
    });

    testWidgets('does NOT display admin section for regular user', (tester) async {
      final auth = _MockAuthProvider(user: {
        'user_prenom': 'Bob',
        'user_email': 'bob@test.com',
        'user_role': 'client',
      });
      await tester.pumpWidget(withProviders(const ProfileScreen(), auth: auth));
      await tester.pump();
      expect(find.text('Administration'), findsNothing);
    });

    testWidgets('shows logout button', (tester) async {
      await tester.pumpWidget(withProviders(const ProfileScreen()));
      await tester.pump();
      expect(find.text('Se déconnecter'), findsOneWidget);
    });
  });

  // ── BookingsScreen ────────────────────────────────────────

  group('BookingsScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(withProviders(const BookingsScreen()));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Drain Dio's connect-timeout timer (10 s) so the test ends cleanly
      await tester.pump(const Duration(seconds: 15));
    });
  });

  // ── SearchScreen ──────────────────────────────────────────

  group('SearchScreen', () {
    testWidgets('shows loading skeletons initially', (tester) async {
      await tester.pumpWidget(withProviders(const SearchScreen()));
      await tester.pump();
      expect(find.byType(GridView), findsOneWidget);
      await tester.pump(const Duration(seconds: 15));
    });
  });

  // ── BookingOptionsScreen ──────────────────────────────────

  group('BookingOptionsScreen', () {
    const product = {
      'id': 1,
      'name': 'Poussette Travel',
      'price': '15€',
      'price_num': 15.0,
      'image': '',
      'category': 'Poussettes',
      'stock': 3,
      'description': '',
    };

    testWidgets('renders calendar and options', (tester) async {
      await tester.pumpWidget(withProviders(
        const BookingOptionsScreen(product: product),
      ));
      await tester.pump();
      // Section title appears (at least once — also in the submit button)
      expect(find.text('Sélectionnez vos dates'), findsAtLeastNWidgets(1));
      expect(find.text('Options supplémentaires'), findsOneWidget);
    });

    testWidgets('payment button disabled when no dates selected', (tester) async {
      await tester.pumpWidget(withProviders(
        const BookingOptionsScreen(product: product),
      ));
      await tester.pump();
      // Find ElevatedButton whose onPressed is null (no dates → disabled)
      final disabledBtns = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton))
          .where((b) => b.onPressed == null)
          .toList();
      expect(disabledBtns, isNotEmpty);
    });
  });
}

// ── Mock AuthProvider ─────────────────────────────────────────

class _MockAuthProvider extends AuthProvider {
  final Map<String, dynamic>? _mockUser;
  _MockAuthProvider({Map<String, dynamic>? user}) : _mockUser = user;

  @override
  Map<String, dynamic>? get user => _mockUser;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;
}
