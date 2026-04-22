part of 'app_language_bloc.dart';

abstract class AppLanguageEvent extends Equatable {
  const AppLanguageEvent();

  @override
  List<Object?> get props => [];
}

class ChangeAppLanguage extends AppLanguageEvent {
  const ChangeAppLanguage({
    required this.selectedLanguage,
  });

  final AppLanguage selectedLanguage;

  @override
  List<Object?> get props => [selectedLanguage];
}

class LoadAppLanguage extends AppLanguageEvent {
  const LoadAppLanguage();
}
