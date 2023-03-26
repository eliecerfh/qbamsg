// Importa las dependencias necesarias
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define el widget LoginPage como un StatefulWidget
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

// Define una ruta estática para poder navegar a esta página
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

// Crea y retorna una nueva instancia de _LoginPageState
  @override
  _LoginPageState createState() => _LoginPageState();
}

// Define el estado del widget LoginPage
class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

// Define una función asincrónica para realizar el inicio de sesión
  Future<void> _signIn() async {
// Muestra el indicador de carga
    setState(() {
      _isLoading = true;
    });

    try {
      // Intenta realizar el inicio de sesión con Supabase
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      // Si ocurre una excepción de autenticación, muestra un mensaje de error
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      // Si ocurre cualquier otra excepción, muestra un mensaje de error genérico
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

// Oculta el indicador de carga
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

// Libera los recursos utilizados por los controladores de texto
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

// Construye la interfaz de usuario del widget LoginPage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
// Define la barra de aplicación
      appBar: AppBar(
        title: const Text('LOGIN'),
        centerTitle: true,
      ),
// Define el cuerpo de la página
      body: ListView(
        padding: formPadding,
        children: [
          Container(
            height: 200,
          ),
// Crea un campo de texto para el correo electrónico
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          spacer,
// Crea un campo de texto para la contraseña
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          spacer,
// Crea un botón para iniciar sesión
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
