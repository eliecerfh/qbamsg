import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './cubits/profiles/profiles_cubit.dart';
import './utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // TODO: Replace credentials with your own
    url: 'https://jpzvwxorgzcbrzzifhhb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwenZ3eG9yZ3pjYnJ6emlmaGhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2Nzk2OTYzNzgsImV4cCI6MTk5NTI3MjM3OH0.1zhJznu504y9rNZLosyTRONRRgBnAwTG6h71NTI1B_0',
    authCallbackUrlHostname: 'login',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfilesCubit>(
      create: (context) => ProfilesCubit(),
      child: MaterialApp(
        title: 'SupaChat',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const SplashPage(),
      ),
    );
  }
}
