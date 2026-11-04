import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/ui/authentication/widgets/forgot_password_screen.dart';
import 'package:united2/ui/authentication/widgets/login_screen.dart';
import 'package:united2/ui/authentication/widgets/register_screen.dart';
import 'package:united2/ui/authentication/widgets/verify_email_screen.dart';
import 'package:united2/ui/catalog/widgets/b03_screen.dart';
import 'package:united2/ui/home/widgets/home_screen.dart';
import 'package:united2/ui/catalog/widgets/b01_screen.dart';
import 'package:united2/ui/catalog/widgets/b02_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: FootballApp()));
}
