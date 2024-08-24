import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Authentication Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final User user;

  const AuthLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthEvent {}

// Authentication States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

// Authentication Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  void _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }
}
