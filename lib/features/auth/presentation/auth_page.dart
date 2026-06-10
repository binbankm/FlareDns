import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _apiKeyController.text.trim());
      // Wait for state to settle, then routing will take over via GoRouter redirect
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.cloud, size: 80, color: Theme.of(context).colorScheme.tertiary),
                  SizedBox(height: 16),
                  Text(
                    l10n.authWelcome,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.authSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                  SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.authEmail,
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : l10n.authRequired,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: l10n.authApiKey,
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    obscureText: true,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : l10n.authRequired,
                  ),
                  SizedBox(height: 24),
                  FilledButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.authLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
