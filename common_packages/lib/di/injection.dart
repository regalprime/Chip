import 'package:common_packages/data/data_source/remote_data_source.dart';
import 'package:common_packages/data/repositories_impl/auth_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/day_counter_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/finance_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/friend_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/note_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/photo_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/moment_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/love_letter_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/profile_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/qa_repository_impl.dart';
import 'package:common_packages/data/repositories_impl/wish_repository_impl.dart';
import 'package:common_packages/domain/repositories/auth_repository.dart';
import 'package:common_packages/domain/repositories/day_counter_repository.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';
import 'package:common_packages/domain/repositories/love_letter_repository.dart';
import 'package:common_packages/domain/repositories/moment_repository.dart';
import 'package:common_packages/domain/repositories/note_repository.dart';
import 'package:common_packages/domain/repositories/photo_repository.dart';
import 'package:common_packages/domain/repositories/profile_repository.dart';
import 'package:common_packages/domain/repositories/qa_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';
import 'package:common_packages/domain/repositories/wish_repository.dart';
import 'package:common_packages/domain/usecases/auth/sign_in_with_email_use_case.dart';
import 'package:common_packages/domain/usecases/auth/sign_in_with_google_use_case.dart';
import 'package:common_packages/domain/usecases/auth/sign_out_use_case.dart';
import 'package:common_packages/domain/usecases/auth/sign_up_with_email_use_case.dart';
import 'package:common_packages/domain/usecases/finance/add_category_use_case.dart';
import 'package:common_packages/domain/usecases/finance/add_transaction_use_case.dart';
import 'package:common_packages/domain/usecases/finance/delete_transaction_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_budgets_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_categories_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_overview_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_transactions_use_case.dart';
import 'package:common_packages/domain/usecases/finance/set_budget_use_case.dart';
import 'package:common_packages/domain/usecases/friend/get_friend_requests_use_case.dart';
import 'package:common_packages/domain/usecases/friend/get_friends_use_case.dart';
import 'package:common_packages/domain/usecases/friend/remove_friend_use_case.dart';
import 'package:common_packages/domain/usecases/friend/respond_friend_request_use_case.dart';
import 'package:common_packages/domain/usecases/friend/search_users_use_case.dart';
import 'package:common_packages/domain/usecases/friend/send_friend_request_use_case.dart';
import 'package:common_packages/domain/usecases/note/add_note_use_case.dart';
import 'package:common_packages/domain/usecases/note/delete_note_use_case.dart';
import 'package:common_packages/domain/usecases/note/get_notes_use_case.dart';
import 'package:common_packages/domain/usecases/note/update_note_use_case.dart';
import 'package:common_packages/domain/usecases/photo/delete_photos_use_case.dart';
import 'package:common_packages/domain/usecases/photo/get_photos_use_case.dart';
import 'package:common_packages/domain/usecases/photo/upload_photo_use_case.dart';
import 'package:common_packages/domain/usecases/profile/get_profile_use_case.dart';
import 'package:common_packages/domain/usecases/profile/update_profile_use_case.dart';
import 'package:common_packages/domain/usecases/moment/delete_moment_use_case.dart';
import 'package:common_packages/domain/usecases/moment/get_moments_use_case.dart';
import 'package:common_packages/domain/usecases/moment/react_to_moment_use_case.dart';
import 'package:common_packages/domain/usecases/moment/send_moment_use_case.dart';
import 'package:common_packages/domain/usecases/share/get_shared_feed_use_case.dart';
import 'package:common_packages/domain/usecases/share/share_item_use_case.dart';
import 'package:common_packages/presentation/blocs/auth/auth_bloc.dart';
import 'package:common_packages/presentation/blocs/counter_day/day_counter_bloc.dart';
import 'package:common_packages/presentation/blocs/feed/feed_bloc.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:common_packages/presentation/blocs/friend/friend_bloc.dart';
import 'package:common_packages/presentation/blocs/note/note_bloc.dart';
import 'package:common_packages/presentation/blocs/moment/moment_bloc.dart';
import 'package:common_packages/presentation/blocs/photo/photo_bloc.dart';
import 'package:common_packages/presentation/blocs/love_letter/love_letter_bloc.dart';
import 'package:common_packages/presentation/blocs/profile/profile_bloc.dart';
import 'package:common_packages/presentation/blocs/qa/qa_bloc.dart';
import 'package:common_packages/presentation/blocs/wish/wish_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<firebase.FirebaseAuth>(() => firebase.FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ─── Data Sources ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      supabaseClient: sl(),
    ),
  );

  // ─── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DayCounterRepository>(
    () => DayCounterRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PhotoRepository>(
    () => PhotoRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MomentRepository>(
    () => MomentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WishRepository>(
    () => WishRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<QaRepository>(
    () => QaRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LoveLetterRepository>(
    () => LoveLetterRepositoryImpl(remoteDataSource: sl()),
  );

  // ─── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => UploadPhotoUseCase(sl()));
  sl.registerLazySingleton(() => GetPhotosUseCase(sl()));
  sl.registerLazySingleton(() => DeletePhotosUseCase(sl()));
  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton(() => AddNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  sl.registerLazySingleton(() => SendFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => RespondFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendsUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendRequestsUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFriendUseCase(sl()));
  sl.registerLazySingleton(() => ShareItemUseCase(sl()));
  sl.registerLazySingleton(() => GetSharedFeedUseCase(sl()));
  sl.registerLazySingleton(() => GetMomentsUseCase(sl()));
  sl.registerLazySingleton(() => SendMomentUseCase(sl()));
  sl.registerLazySingleton(() => ReactToMomentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMomentUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetFinanceCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddFinanceCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetFinanceOverviewUseCase(sl()));
  sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => SetBudgetUseCase(sl()));

  // ─── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithGoogleUseCase: sl(),
      signInWithEmailUseCase: sl(),
      signUpWithEmailUseCase: sl(),
      signOutUseCase: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerFactory<DayCounterBloc>(
    () => DayCounterBloc(
      dayCounterRepository: sl(),
    )..add(const LoadDayCountersEvent()),
  );
  sl.registerFactory<PhotoBloc>(
    () => PhotoBloc(
      uploadPhotoUseCase: sl(),
      getPhotosUseCase: sl(),
      deletePhotosUseCase: sl(),
    )..add(const LoadPhotosEvent()),
  );
  sl.registerFactory<NoteBloc>(
    () => NoteBloc(
      getNotesUseCase: sl(),
      addNoteUseCase: sl(),
      updateNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
    )..add(const LoadNotesEvent()),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );
  sl.registerFactory<FriendBloc>(
    () => FriendBloc(
      searchUsersUseCase: sl(),
      sendFriendRequestUseCase: sl(),
      respondFriendRequestUseCase: sl(),
      getFriendsUseCase: sl(),
      getFriendRequestsUseCase: sl(),
      removeFriendUseCase: sl(),
    )..add(const LoadFriendsEvent())..add(const LoadFriendRequestsEvent()),
  );
  sl.registerFactory<FeedBloc>(
    () => FeedBloc(
      getSharedFeedUseCase: sl(),
      shareItemUseCase: sl(),
    )..add(const LoadFeedEvent()),
  );
  sl.registerFactory<FinanceBloc>(
    () => FinanceBloc(
      getTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      deleteTransactionUseCase: sl(),
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      getOverviewUseCase: sl(),
      getBudgetsUseCase: sl(),
      setBudgetUseCase: sl(),
    ),
  );
  sl.registerFactory<MomentBloc>(
    () => MomentBloc(
      getMomentsUseCase: sl(),
      sendMomentUseCase: sl(),
      reactToMomentUseCase: sl(),
      deleteMomentUseCase: sl(),
    )..add(const LoadMomentsEvent()),
  );
  sl.registerFactory<WishBloc>(
    () => WishBloc(wishRepository: sl())..add(const LoadWishesEvent()),
  );
  sl.registerFactory<QaBloc>(
    () => QaBloc(qaRepository: sl()),
  );
  sl.registerFactory<LoveLetterBloc>(
    () => LoveLetterBloc(loveLetterRepository: sl())
      ..add(const LoadSentLettersEvent())
      ..add(const LoadReceivedLettersEvent()),
  );
}
