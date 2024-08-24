import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_bloc.dart';
import '../login_page.dart';
import '../value_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure that AuthBloc is available in the context
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      // Handle the case where the user is not authenticated
      return Center(child: Text('User not authenticated'));
    }

    final user = authState.user;
    return BlocProvider(
      create: (context) => ValueBloc(user.uid)..add(ValueFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLoggedOut());
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginPage()));
              },
            ),
          ],
        ),
        body: BlocBuilder<ValueBloc, ValueState>(
          builder: (context, state) {
            if (state is ValueLoadSuccess) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Value: ${state.value}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ValueBloc>().add(ValueIncremented());
                      },
                      child: Text('Increment'),
                    ),
                  ],
                ),
              );
            } else if (state is ValueLoadFailure) {
              return Center(
                child: Text('Failed to load value: ${state.message}'),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
