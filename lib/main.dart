import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config.dart';
import 'firebase_options.dart';
import 'models/app_user.dart';
import 'auth_gate.dart';
import 'state/auth_state.dart';
import 'state/cart_state.dart';
import 'state/catalog_state.dart';
import 'state/orders_state.dart';
import 'state/reviews_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppFlavor.role = UserRole.admin;

  if (AppConfig.useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const AptekaApp());
}

class AptekaApp extends StatelessWidget {
  const AptekaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => CartState()),
        ChangeNotifierProvider(create: (_) => CatalogState()),
        ChangeNotifierProvider(create: (_) => OrdersState()),
        ChangeNotifierProvider(create: (_) => ReviewsState()),
      ],
      child: MaterialApp(
        title: AppFlavor.title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}
