import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/app_colors.dart';
import '../core/routes.dart';
import '../services/auth_api.dart';
import '../state/session_store.dart';
import '../widgets/top_brown_header.dart';
import '../widgets/white_panel.dart';
import '../widgets/segment_button.dart';
import '../widgets/input_field.dart';
import '../widgets/buttons.dart';

class AuthScreen extends StatefulWidget {
  final SessionStore session;
  const AuthScreen({super.key, required this.session});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _submit() async {
    final e = email.text.trim();
    final p = password.text;

    if (e.isEmpty || !e.contains('@')) return _msg('Enter a valid email');
    if (p.length < 6) return _msg('Password must be at least 6 characters');

    try {
      if (!isLogin) {
        final u = username.text.trim();
        if (u.length < 2) return _msg('Enter username');
        if (confirm.text != p) return _msg('Passwords do not match');

        await AuthApi.register(email: e, password: p, username: u);
        _msg('Account created. Login now.');
        setState(() => isLogin = true);
        return;
      }

      // ✅ UPDATED: AuthApi.login now SAVES session inside SessionStore
      await AuthApi.login(email: e, password: p, session: widget.session);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.app, (_) => false);
    } catch (err) {
      _msg(err.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          TopBrownHeader(
            title: '',
            subtitleAlign: TextAlign.center,
            right: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border_rounded,
                  color: Colors.white),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 56,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Taste',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Hub',
                          style: TextStyle(color: AppColors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/images/Burger.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: WhitePanel(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SegmentButton(
                              text: 'Login',
                              selected: isLogin,
                              onTap: () => setState(() => isLogin = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SegmentButton(
                              text: 'Sign Up',
                              selected: !isLogin,
                              onTap: () => setState(() => isLogin = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isLogin) ...[
                        InputField(controller: username, hint: 'Username'),
                        const SizedBox(height: 12),
                      ],
                      InputField(
                        controller: email,
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      InputField(
                        controller: password,
                        hint: 'Password',
                        obscure: true,
                      ),
                      if (!isLogin) ...[
                        const SizedBox(height: 12),
                        InputField(
                          controller: confirm,
                          hint: 'Confirm password',
                          obscure: true,
                        ),
                      ],
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: isLogin ? 'Login' : 'Create account',
                        onTap: _submit,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'or',
                        style: TextStyle(
                          color: AppColors.textMute,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIcon(icon: FontAwesomeIcons.facebookF),
                          SizedBox(width: 14),
                          _SocialIcon(icon: FontAwesomeIcons.google),
                          SizedBox(width: 14),
                          _SocialIcon(icon: FontAwesomeIcons.xTwitter),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.field),
      ),
      child: Center(
        child: FaIcon(icon, size: 18, color: AppColors.brown),
      ),
    );
  }
}
