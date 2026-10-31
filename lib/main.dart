import 'package:flutter/material.dart';

void main() => runApp(const DevUnleashedApp());

const kBackground = Color(0xFF0B0F1A);
const kSurface = Color(0xFF141A2B);
const kBorder = Color(0xFF263049);
const kAccent = Color(0xFF3B82F6);
const kMuted = Color(0xFF8A94A8);

OutlineInputBorder outline(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(color: color),
);

class DevUnleashedApp extends StatelessWidget {
  const DevUnleashedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevUnleashed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        colorScheme: const ColorScheme.dark(primary: kAccent),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          labelStyle: const TextStyle(color: kMuted),
          border: outline(kBorder),
          enabledBorder: outline(kBorder),
          focusedBorder: outline(kAccent),
          errorBorder: outline(Colors.redAccent),
          focusedErrorBorder: outline(Colors.redAccent),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// Validators

String? validateName(String? v) =>
    (v == null || v.trim().length < 2) ? 'Enter your full name' : null;

String? validateEmail(String? v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
    ? null
    : 'Enter a valid email address';

String? validatePassword(String? v) =>
    (v == null || v.length < 6) ? 'Use at least 6 characters' : null;

// Describes one input field

class FieldSpec {
  const FieldSpec(
    this.label,
    this.icon,
    this.validator, {
    this.isPassword = false,
    this.isConfirm = false,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final bool isPassword;
  final bool isConfirm; // must match the field above it
  final TextInputType? keyboardType;
}

// Shared screen: logo, title, fields (with show/hide), button, footer link

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.buttonLabel,
    required this.successMessage,
    required this.footerText,
    required this.footerAction,
    required this.onFooterTap,
    this.onForgotPassword,
  });

  final String title;
  final String subtitle;
  final List<FieldSpec> fields;
  final String buttonLabel;
  final String successMessage;
  final String footerText;
  final String footerAction;
  final VoidCallback onFooterTap;
  final VoidCallback? onForgotPassword;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final Set<int> _shown = {}; // indexes of password fields currently visible
  late final List<TextEditingController> _controllers = [
    for (final _ in widget.fields) TextEditingController(),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.successMessage)));
    }
  }

  Widget _field(int i) {
    final spec = widget.fields[i];
    final hidden = spec.isPassword && !_shown.contains(i);
    return TextFormField(
      controller: _controllers[i],
      keyboardType: spec.keyboardType,
      obscureText: hidden,
      validator: (v) => spec.isConfirm
          ? (v == _controllers[i - 1].text ? null : 'Passwords do not match')
          : spec.validator(v),
      decoration: InputDecoration(
        labelText: spec.label,
        prefixIcon: Icon(spec.icon, color: kMuted),
        suffixIcon: spec.isPassword
            ? IconButton(
                color: kMuted,
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => hidden ? _shown.add(i) : _shown.remove(i)),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/devunleashed_logo.png',
                    height: 72,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kMuted),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        for (var i = 0; i < widget.fields.length; i++) ...[
                          if (i > 0) const SizedBox(height: 16),
                          _field(i),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onForgotPassword != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(widget.buttonLabel),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.footerText,
                        style: const TextStyle(color: kMuted),
                      ),
                      TextButton(
                        onPressed: widget.onFooterTap,
                        child: Text(widget.footerAction),
                      ),
                    ],
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

// Login page

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Welcome back',
      subtitle: 'Log in to continue to DevUnleashed',
      fields: const [
        FieldSpec(
          'Email',
          Icons.mail_outline,
          validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        FieldSpec(
          'Password',
          Icons.lock_outline,
          validatePassword,
          isPassword: true,
        ),
      ],
      buttonLabel: 'Log in',
      onForgotPassword: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset coming soon (UI only)')),
      ),
      successMessage: 'Login successful (UI only)',
      footerText: "Don't have an account?",
      footerAction: 'Register',
      onFooterTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const RegisterPage())),
    );
  }
}

// Register page

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Create account',
      subtitle: 'Join DevUnleashed and build without limits',
      fields: const [
        FieldSpec('Full name', Icons.person_outline, validateName),
        FieldSpec(
          'Email',
          Icons.mail_outline,
          validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        FieldSpec(
          'Password',
          Icons.lock_outline,
          validatePassword,
          isPassword: true,
        ),
        FieldSpec(
          'Confirm password',
          Icons.lock_outline,
          validatePassword,
          isPassword: true,
          isConfirm: true,
        ),
      ],
      buttonLabel: 'Create account',
      successMessage: 'Account created (UI only)',
      footerText: 'Already have an account?',
      footerAction: 'Log in',
      onFooterTap: () => Navigator.of(context).pop(),
    );
  }
}
