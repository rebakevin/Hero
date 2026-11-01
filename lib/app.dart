import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth.dart';
import 'features/home/home.dart';

class HeroApp extends StatelessWidget {
  const HeroApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(
          authRepository: authRepository,
          userRepository: userRepository,
        ),
        child: MaterialApp(
          title: 'Hero',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: AuthGate(
            authenticatedBuilder: (context, user) => HomeShell(user: user),
          ),
        ),
      ),
    );
  }
}
