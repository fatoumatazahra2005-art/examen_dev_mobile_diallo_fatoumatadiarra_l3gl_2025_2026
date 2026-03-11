import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Fonction de connexion
  Future<void> _login() async {
    // Validation formulaire
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Affiche le loader

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Appel login
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      //  Si succès → navigation HomeScreen
      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
      //  Sinon → afficher erreur
      else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? "Erreur de connexion")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur inattendue : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Arrête le loader
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// EMAIL
              CustomTextField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email obligatoire";
                  if (!value.contains("@") || !value.contains("."))
                    return "Email invalide";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              CustomTextField(
                label: "Mot de passe",
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Mot de passe obligatoire";
                  if (value.length < 6) return "Minimum 6 caractères";
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// BOUTON LOGIN
              CustomButton(
                text: "Se connecter",
                isLoading: _isLoading,
                onPressed: _login,
              ),

              const SizedBox(height: 20),

              /// BOUTON S'INSCRIRE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pas de compte ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}