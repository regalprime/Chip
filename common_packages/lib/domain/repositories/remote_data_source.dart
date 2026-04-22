import 'package:common_packages/data/models/day_counter/day_counter_model.dart';
import 'package:common_packages/data/models/finance/budget_model.dart';
import 'package:common_packages/data/models/finance/finance_category_model.dart';
import 'package:common_packages/data/models/finance/transaction_model.dart';
import 'package:common_packages/data/models/friendship/friendship_model.dart';
import 'package:common_packages/data/models/love_letter/love_letter_model.dart';
import 'package:common_packages/data/models/moment/moment_model.dart';
import 'package:common_packages/data/models/qa/qa_answer_model.dart';
import 'package:common_packages/data/models/wish/wish_model.dart';
import 'package:common_packages/domain/entities/finance/finance_overview.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/data/models/note/note_model.dart';
import 'package:common_packages/data/models/photo/photo_model.dart';
import 'package:common_packages/data/models/share/shared_item_model.dart';
import 'package:common_packages/data/models/user/user_model.dart';

abstract class RemoteDataSource {
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithEmail({required String email, required String password});
  Future<UserModel?> signUpWithEmail({required String email, required String password});
  Future<void> saveUserToSupabase(UserModel user);
  Future<UserModel?> getCurrentUserOnce();
  Stream<UserModel?> getCurrentUserStream();
  Future<void> signOut();

  Future<PhotoModel> uploadPhoto({required String filePath});
  Future<List<PhotoModel>> getPhotos();
  Future<void> deletePhotos({required List<String> photoIds});

  Future<List<NoteModel>> getNotes();
  Future<NoteModel> addNote({required String title, required String content});
  Future<NoteModel> updateNote({required String id, required String title, required String content});
  Future<void> deleteNote({required String id});

  // Profile
  Future<UserModel> updateProfile({required String displayName, String? bio, String? avatarFilePath});
  Future<UserModel> getProfile();

  // Friends
  Future<List<UserModel>> searchUsers({required String query});
  Future<FriendshipModel> sendFriendRequest({required String addresseeId});
  Future<void> respondFriendRequest({required String friendshipId, required bool accept});
  Future<List<FriendshipModel>> getFriendRequests();
  Future<List<FriendshipModel>> getFriends();
  Future<void> removeFriend({required String friendshipId});

  // Share
  Future<void> shareItem({required String friendId, required String itemId, required String itemType});
  Future<List<SharedItemModel>> getSharedFeed();

  // Moments
  Future<MomentModel> sendMoment({String? content, String? imagePath, String? mood});
  Future<List<MomentModel>> getMoments();
  Future<MomentReactionModel> reactToMoment({required String momentId, required String emoji});
  Future<void> deleteMoment({required String momentId});

  // Documents
  Future<List<Map<String, dynamic>>> getDocuments();
  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String fileName,
    required String fileType,
    int? fileSize,
    String? textContent,
  });
  Future<void> deleteDocument({required String id, required String fileUrl});

  // Day Counters
  Future<List<DayCounterModel>> getDayCounters();
  Future<DayCounterModel> addDayCounter({
    required String title,
    required DateTime targetDate,
    String emoji,
    String colorHex,
    String? note,
  });
  Future<DayCounterModel> updateDayCounter({
    required String id,
    required String title,
    required DateTime targetDate,
    String emoji,
    String colorHex,
    String? note,
  });
  Future<void> deleteDayCounter({required String id});

  // Finance
  Future<List<TransactionModel>> getTransactions({required int month, required int year});
  Future<TransactionModel> addTransaction({
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  });
  Future<TransactionModel> updateTransaction({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  });
  Future<void> deleteTransaction({required String id});
  Future<List<FinanceCategoryModel>> getFinanceCategories();
  Future<FinanceCategoryModel> addFinanceCategory({
    required String name,
    required String icon,
    required String color,
    required TransactionType type,
  });
  Future<List<BudgetModel>> getBudgets({required int month, required int year});
  Future<BudgetModel> setBudget({
    required String categoryId,
    required int amount,
    required int month,
    required int year,
  });
  Future<FinanceOverview> getFinanceOverview({required int month, required int year});

  // Current user UID helper
  Future<String> getCurrentUid();

  // Wishes
  Future<List<WishModel>> getWishes();
  Future<WishModel> addWish({required String title, String? description, String emoji});
  Future<WishModel> updateWish({required String id, required String title, String? description, String emoji});
  Future<WishModel> completeWish({required String id, String? completionNote});
  Future<WishModel> uncompleteWish({required String id});
  Future<void> deleteWish({required String id});

  // Q&A
  Future<List<QaAnswerModel>> getQaAnswersForDate({required String friendshipId, required DateTime date});
  Future<QaAnswerModel> submitQaAnswer({
    required String friendshipId,
    required int questionIndex,
    required DateTime questionDate,
    required String answerText,
  });
  Future<List<QaAnswerModel>> getQaAnswerHistory({required String friendshipId});

  // Love Letters
  Future<List<LoveLetterModel>> getSentLetters();
  Future<List<LoveLetterModel>> getReceivedLetters();
  Future<LoveLetterModel> sendLoveLetter({
    required String recipientId,
    required String title,
    required String content,
    required DateTime deliveryDate,
  });
  Future<LoveLetterModel> markLetterAsRead({required String id});
  Future<void> deleteLoveLetter({required String id});
}
