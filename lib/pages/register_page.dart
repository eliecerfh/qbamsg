// ignore_for_file: use_build_context_synchronously

// Importación de paquetes y archivos necesarios
import 'dart:async';
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/rooms_page.dart';
import '../utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definición de un widget de página de registro que se puede utilizar en la aplicación.
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

// Definición de una ruta de página de registro para poder navegar a ella.
  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

// Variable booleana que indica si el usuario está registrando una cuenta nueva.
  final bool isRegistering;

// Método para crear el estado del widget RegisterPage.
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Clase de estado del widget RegisterPage.
class _RegisterPageState extends State<RegisterPage> {
// Variable booleana que indica si la página está cargando.
  final bool _isLoading = false;

// Llave global para el formulario de registro.
  final _formKey = GlobalKey<FormState>();

// Controladores de texto para los campos de correo electrónico, contraseña y nombre de usuario.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

// Suscripción a cambios en el estado de autenticación.
  late final StreamSubscription<AuthState> _authSubscription;

// Método que se llama cuando se inicializa el estado del widget RegisterPage.
  @override
  void initState() {
    super.initState();

// Variable booleana que indica si el usuario ha navegado a otra página.
    bool haveNavigated = false;

// Escuchar cambios en el estado de autenticación para redirigir al usuario cuando haga clic en el enlace de confirmación.
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !haveNavigated) {
        haveNavigated = true;
        Navigator.of(context).pushReplacement(RoomsPage.route());
      }
    });
  }

// Método para liberar recursos cuando el widget RegisterPage ya no es necesario.
  @override
  void dispose() {
    super.dispose();

// Cancelar la suscripción a cambios en el estado de autenticación.
    _authSubscription.cancel();
  }

// Método para registrar una nueva cuenta de usuario.
  Future<void> _signUp() async {
// Validar el formulario de registro.
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    try {
// Registrar una nueva cuenta de usuario.
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
        emailRedirectTo: 'io.supabase.chat://login',
      );
      context.showSnackBar(
          message: 'Please check your inbox for confirmation email.');
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      debugPrint(error.toString());
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

// Método para construir la interfaz de usuario del widget RegisterPage.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTER'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            Container(
              height: 200,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            spacer,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                if (val.length < 6) {
                  return '6 characters minimum';
                }
                return null;
              },
            ),
            spacer,
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Text('Username'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                final isValid = RegExp(r'^[A-Za-z0-9]{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3-24 long with alphanumeric or underscore';
                }
                return null;
              },
            ),
            spacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('Register'),
            ),
            spacer,
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: const Text(
                  'I already have an account',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
