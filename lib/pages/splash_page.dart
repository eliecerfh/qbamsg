/// Importamos las librerías necesarias para el funcionamiento de la página
import 'package:flutter/material.dart';
import '../pages/register_page.dart';
import '../pages/rooms_page.dart';
import '../utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Página para redirigir a los usuarios a la página adecuada según el estado de autenticación inicial
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
// Obtenemos la sesión inicial
    getInitialSession();
    super.initState();
  }

  Future<void> getInitialSession() async {
// Forma rápida y sucia de esperar a que el widget se monte
    await Future.delayed(Duration.zero);

    try {
      // Obtenemos la sesión inicial de Supabase
      final session = await SupabaseAuth.instance.initialSession;
      if (session == null) {
        // Si no hay sesión, redirigimos a la página de registro
        Navigator.of(context)
            .pushAndRemoveUntil(RegisterPage.route(), (_) => false);
      } else {
        // Si hay sesión, redirigimos a la página de habitaciones
        Navigator.of(context).pushReplacementNamed(RoomsPage.route() as String,
            result: (_) => false);
      }
    } catch (_) {
      // Si hay un error, mostramos una barra de errores y redirigimos a la página de registro
      context.showErrorSnackBar(
        message: 'Error occured during session refresh',
      );
      Navigator.of(context)
          .pushAndRemoveUntil(RegisterPage.route(), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
// Retornamos un Scaffold con un indicador de carga en el centro
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
