import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  /// Fonction d'inscription
  Future<void> _register() async {
    //  Validation du formulaire
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Affiche le loader

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      //  Appel à la fonction register de AuthProvider
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      //  Si succès → navigation vers HomeScreen
      if (success && mounted) {
        await authProvider.printUsers();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
      // Sinon → afficher erreur
      else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? "Erreur d'inscription")),
        );
      }
    } catch (e) {
      // Gestion d'erreur inattendue
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur inattendue : $e")),
        );
      }
    } finally {
      // Toujours arrêter le loader
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// NOM
              CustomTextField(
                label: "Nom",
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nom obligatoire";
                  if (value.length < 2) return "Minimum 2 caractères";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// EMAIL
              CustomTextField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email obligatoire";
                  if (!value.contains("@") || !value.contains(".")) return "Email invalide";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// MOT DE PASSE
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

              const SizedBox(height: 16),

              /// CONFIRM PASSWORD
              CustomTextField(
                label: "Confirmer le mot de passe",
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) return "Les mots de passe ne correspondent pas";
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// BOUTON INSCRIPTION
              CustomButton(
                text: "S'inscrire",
                isLoading: _isLoading,
                onPressed: _register,
              ),

              const SizedBox(height: 20),

              /// LIEN LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Se connecter",
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