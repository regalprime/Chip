import 'dart:io';

import 'package:common_packages/core/error/exception.dart';
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
import 'package:common_packages/domain/repositories/remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final firebase.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final SupabaseClient _supabaseClient;

  RemoteDataSourceImpl({
    required firebase.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required SupabaseClient supabaseClient,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _supabaseClient = supabaseClient;

  /// Ensures the current Firebase user exists in Supabase `users` table.
  /// Call before any operation with FK to `users`.
  Future<void> _ensureUserExists() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _supabaseClient.from('users').upsert({
      'uid': user.uid,
      'email': user.email ?? 'no-email',
      'display_name': user.displayName,
      'photo_url': user.photoURL,
    }, onConflict: 'uid');
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Đăng nhập Google qua Firebase
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled');
        return null; // User cancelled
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw ServerException('No user returned from Firebase');
      }

      // Tạo UserModel từ Firebase user
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? 'no-email',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      // Lưu user vào Supabase
      try {
        await saveUserToSupabase(userModel);
        print('User saved to Supabase: ${userModel.uid}');
      } catch (e) {
        print('Save user error: $e');
        throw ServerException('Failed to save user to Supabase: $e');
      }

      return userModel;
    } catch (e) {
      print('Sign-in error: $e');
      throw ServerException('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw ServerException('No user returned from Firebase');
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      await saveUserToSupabase(userModel);
      return userModel;
    } catch (e) {
      throw ServerException('Failed to sign in with email: $e');
    }
  }

  @override
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw ServerException('No user returned from Firebase');
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      await saveUserToSupabase(userModel);
      return userModel;
    } catch (e) {
      throw ServerException('Failed to sign up with email: $e');
    }
  }

  @override
  Future<void> saveUserToSupabase(UserModel user) async {
    try {
      await _supabaseClient.from('users').upsert(user.toJson(), onConflict: 'uid');
      print('User saved to Supabase: ${user.uid}');
    } catch (e) {
      print('Save user error: $e');
      throw ServerException('Failed to save user to Supabase: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUserOnce() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return null;
      return UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? 'no-email',
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoURL,
      );
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  @override
  Stream<UserModel?> getCurrentUserStream() {
    return _firebaseAuth
        .authStateChanges()
        .map((firebase.User? user) {
          if (user == null) return null;
          return UserModel(
            uid: user.uid,
            email: user.email ?? 'no-email',
            displayName: user.displayName,
            photoUrl: user.photoURL,
          );
        })
        .handleError((e) {
          throw ServerException('Auth state change error: $e');
        });
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      print('Signed out successfully');
    } catch (e) {
      throw ServerException('Failed to sign out: $e');
    }
  }

  @override
  Future<PhotoModel> uploadPhoto({required String filePath}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final file = File(filePath);
      final fileName = '${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

      await _supabaseClient.storage.from('photos').upload(fileName, file);

      final url = _supabaseClient.storage.from('photos').getPublicUrl(fileName);

      final response = await _supabaseClient.from('photos').insert({
        'url': url,
        'user_id': user.uid,
      }).select().single();

      return PhotoModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to upload photo: $e');
    }
  }

  @override
  Future<List<PhotoModel>> getPhotos() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('photos')
          .select()
          .eq('user_id', user.uid)
          .order('created_at', ascending: false);

      return response.map((json) => PhotoModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get photos: $e');
    }
  }

  @override
  Future<void> deletePhotos({required List<String> photoIds}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      // Lấy thông tin ảnh để xoá file trong storage
      final photos = await _supabaseClient
          .from('photos')
          .select('id, url')
          .inFilter('id', photoIds)
          .eq('user_id', user.uid);

      // Xoá file trong Supabase Storage
      final storagePaths = <String>[];
      for (final photo in photos) {
        final url = photo['url'] as String;
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        // Path format: /storage/v1/object/public/photos/{userId}/{filename}
        final photosIndex = segments.indexOf('photos');
        if (photosIndex != -1 && photosIndex + 1 < segments.length) {
          final storagePath = segments.sublist(photosIndex + 1).join('/');
          storagePaths.add(storagePath);
        }
      }

      if (storagePaths.isNotEmpty) {
        await _supabaseClient.storage.from('photos').remove(storagePaths);
      }

      // Xoá record trong database
      await _supabaseClient
          .from('photos')
          .delete()
          .inFilter('id', photoIds)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete photos: $e');
    }
  }

  // ─── Notes ──────────────────────────────────────────────────────────────────

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('notes')
          .select()
          .eq('user_id', user.uid)
          .order('updated_at', ascending: false);

      return response.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get notes: $e');
    }
  }

  @override
  Future<NoteModel> addNote({required String title, required String content}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient.from('notes').insert({
        'title': title,
        'content': content,
        'user_id': user.uid,
      }).select().single();

      return NoteModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add note: $e');
    }
  }

  @override
  Future<NoteModel> updateNote({required String id, required String title, required String content}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('notes')
          .update({
            'title': title,
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', user.uid)
          .select()
          .single();

      return NoteModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      await _supabaseClient
          .from('notes')
          .delete()
          .eq('id', id)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete note: $e');
    }
  }

  // ─── Profile ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> getProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('uid', user.uid)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to get profile: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String displayName,
    String? bio,
    String? avatarFilePath,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      String? photoUrl;
      if (avatarFilePath != null) {
        final file = File(avatarFilePath);
        final fileName = '${user.uid}/avatar_${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _supabaseClient.storage.from('avatars').upload(fileName, file,
            fileOptions: const FileOptions(upsert: true));
        photoUrl = _supabaseClient.storage.from('avatars').getPublicUrl(fileName);
      }

      final updates = <String, dynamic>{
        'display_name': displayName,
        'bio': bio,
      };
      if (photoUrl != null) {
        updates['photo_url'] = photoUrl;
      }

      final response = await _supabaseClient
          .from('users')
          .update(updates)
          .eq('uid', user.uid)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }

  // ─── Friends ────────────────────────────────────────────────────────────────

  @override
  Future<List<UserModel>> searchUsers({required String query}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('users')
          .select()
          .neq('uid', user.uid)
          .or('email.ilike.%$query%,display_name.ilike.%$query%')
          .limit(20);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to search users: $e');
    }
  }

  @override
  Future<FriendshipModel> sendFriendRequest({required String addresseeId}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient.from('friendships').insert({
        'requester_id': user.uid,
        'addressee_id': addresseeId,
        'status': 'pending',
      }).select('*, requester:users!friendships_requester_id_fkey(*), addressee:users!friendships_addressee_id_fkey(*)').single();

      return FriendshipModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> respondFriendRequest({required String friendshipId, required bool accept}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      if (accept) {
        await _supabaseClient
            .from('friendships')
            .update({'status': 'accepted'})
            .eq('id', friendshipId)
            .eq('addressee_id', user.uid);
      } else {
        await _supabaseClient
            .from('friendships')
            .delete()
            .eq('id', friendshipId)
            .eq('addressee_id', user.uid);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to respond to friend request: $e');
    }
  }

  @override
  Future<List<FriendshipModel>> getFriendRequests() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('friendships')
          .select('*, requester:users!friendships_requester_id_fkey(*), addressee:users!friendships_addressee_id_fkey(*)')
          .eq('addressee_id', user.uid)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response.map((json) => FriendshipModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get friend requests: $e');
    }
  }

  @override
  Future<List<FriendshipModel>> getFriends() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('friendships')
          .select('*, requester:users!friendships_requester_id_fkey(*), addressee:users!friendships_addressee_id_fkey(*)')
          .eq('status', 'accepted')
          .or('requester_id.eq.${user.uid},addressee_id.eq.${user.uid}')
          .order('created_at', ascending: false);

      return response.map((json) => FriendshipModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get friends: $e');
    }
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      await _supabaseClient
          .from('friendships')
          .delete()
          .eq('id', friendshipId)
          .or('requester_id.eq.${user.uid},addressee_id.eq.${user.uid}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to remove friend: $e');
    }
  }

  // ─── Share ──────────────────────────────────────────────────────────────────

  @override
  Future<void> shareItem({
    required String friendId,
    required String itemId,
    required String itemType,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      await _supabaseClient.from('shared_items').insert({
        'owner_id': user.uid,
        'shared_with_id': friendId,
        'item_type': itemType,
        'item_id': itemId,
      });
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to share item: $e');
    }
  }

  @override
  Future<List<SharedItemModel>> getSharedFeed() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('shared_items')
          .select('*, owner:users!shared_items_owner_id_fkey(display_name, photo_url)')
          .eq('shared_with_id', user.uid)
          .order('created_at', ascending: false)
          .limit(50);

      // Enrich với dữ liệu photo/note
      final items = <SharedItemModel>[];
      for (final json in response) {
        final itemType = json['item_type'] as String;
        final itemId = json['item_id'] as String;

        Map<String, dynamic>? itemData;
        if (itemType == 'photo') {
          try {
            itemData = await _supabaseClient
                .from('photos')
                .select('url')
                .eq('id', itemId)
                .single();
            json['photo'] = itemData;
          } catch (_) {}
        } else if (itemType == 'note') {
          try {
            itemData = await _supabaseClient
                .from('notes')
                .select('title, content')
                .eq('id', itemId)
                .single();
            json['note'] = itemData;
          } catch (_) {}
        }

        items.add(SharedItemModel.fromJson(json));
      }

      return items;
    } catch (e) {
      throw ServerException('Failed to get shared feed: $e');
    }
  }

  // ─── Moments ────────────────────────────────────────────────────────────────

  @override
  Future<MomentModel> sendMoment({
    String? content,
    String? imagePath,
    String? mood,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName = '${user.uid}/moment_${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _supabaseClient.storage.from('moments').upload(fileName, file);
        imageUrl = _supabaseClient.storage.from('moments').getPublicUrl(fileName);
      }

      final response = await _supabaseClient.from('moments').insert({
        'user_id': user.uid,
        'content': content,
        'image_url': imageUrl,
        'mood': mood,
      }).select('*, user:users!moments_user_id_fkey(display_name, photo_url), moment_reactions(*, user:users!moment_reactions_user_id_fkey(display_name, photo_url))').single();

      return MomentModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to send moment: $e');
    }
  }

  @override
  Future<List<MomentModel>> getMoments() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      // Lấy danh sách bạn bè (accepted)
      final friendships = await _supabaseClient
          .from('friendships')
          .select('requester_id, addressee_id')
          .eq('status', 'accepted')
          .or('requester_id.eq.${user.uid},addressee_id.eq.${user.uid}');

      final friendIds = <String>{};
      for (final f in friendships) {
        final requesterId = f['requester_id'] as String;
        final addresseeId = f['addressee_id'] as String;
        if (requesterId == user.uid) {
          friendIds.add(addresseeId);
        } else {
          friendIds.add(requesterId);
        }
      }
      // Thêm chính mình để xem moment của mình
      friendIds.add(user.uid);

      if (friendIds.isEmpty) return [];

      final response = await _supabaseClient
          .from('moments')
          .select('*, user:users!moments_user_id_fkey(display_name, photo_url), moment_reactions(*, user:users!moment_reactions_user_id_fkey(display_name, photo_url))')
          .inFilter('user_id', friendIds.toList())
          .order('created_at', ascending: false)
          .limit(50);

      return response.map((json) => MomentModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get moments: $e');
    }
  }

  @override
  Future<MomentReactionModel> reactToMoment({
    required String momentId,
    required String emoji,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      final response = await _supabaseClient.from('moment_reactions').upsert({
        'moment_id': momentId,
        'user_id': user.uid,
        'emoji': emoji,
      }, onConflict: 'moment_id,user_id').select('*, user:users!moment_reactions_user_id_fkey(display_name, photo_url)').single();

      return MomentReactionModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to react to moment: $e');
    }
  }

  @override
  Future<void> deleteMoment({required String momentId}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      // Lấy image_url để xóa file storage
      final moment = await _supabaseClient
          .from('moments')
          .select('image_url')
          .eq('id', momentId)
          .eq('user_id', user.uid)
          .single();

      final imageUrl = moment['image_url'] as String?;
      if (imageUrl != null) {
        final uri = Uri.parse(imageUrl);
        final segments = uri.pathSegments;
        final momentsIndex = segments.indexOf('moments');
        if (momentsIndex != -1 && momentsIndex + 1 < segments.length) {
          final storagePath = segments.sublist(momentsIndex + 1).join('/');
          await _supabaseClient.storage.from('moments').remove([storagePath]);
        }
      }

      await _supabaseClient
          .from('moments')
          .delete()
          .eq('id', momentId)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete moment: $e');
    }
  }

  // ─── Documents ─────────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('documents')
          .select()
          .eq('user_id', user.uid)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get documents: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String fileName,
    required String fileType,
    int? fileSize,
    String? textContent,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _ensureUserExists();

      final file = File(filePath);
      // Sanitize filename for Supabase Storage: only allow ASCII alphanumeric, dash, underscore, dot
      final ext = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      final sanitized = fileName
          .replaceAll(RegExp(r'\.[^.]*$'), '') // remove extension
          .replaceAll(RegExp(r'[^\w\-]'), '_') // replace non-word chars with underscore
          .replaceAll(RegExp(r'_+'), '_')      // collapse multiple underscores
          .trim();
      final storageName = '${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$sanitized$ext';

      await _supabaseClient.storage.from('documents').upload(storageName, file);
      final fileUrl = _supabaseClient.storage.from('documents').getPublicUrl(storageName);

      final response = await _supabaseClient.from('documents').insert({
        'user_id': user.uid,
        'file_name': fileName,
        'file_url': fileUrl,
        'file_type': fileType,
        'file_size': fileSize,
        'text_content': textContent,
      }).select().single();

      return response;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to upload document: $e');
    }
  }

  @override
  Future<void> deleteDocument({required String id, required String fileUrl}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      // Delete from storage
      final uri = Uri.parse(fileUrl);
      final segments = uri.pathSegments;
      final docsIndex = segments.indexOf('documents');
      if (docsIndex != -1 && docsIndex + 1 < segments.length) {
        final storagePath = segments.sublist(docsIndex + 1).join('/');
        await _supabaseClient.storage.from('documents').remove([storagePath]);
      }

      // Delete from database
      await _supabaseClient
          .from('documents')
          .delete()
          .eq('id', id)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete document: $e');
    }
  }

  // ─── Day Counters ───────────────────────────────────────────────────────────

  @override
  Future<List<DayCounterModel>> getDayCounters() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('day_counters')
          .select()
          .eq('user_id', user.uid)
          .order('created_at', ascending: false);

      return response.map((json) => DayCounterModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get day counters: $e');
    }
  }

  @override
  Future<DayCounterModel> addDayCounter({
    required String title,
    required DateTime targetDate,
    String emoji = '❤️',
    String colorHex = 'FFD32F2F',
    String? note,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('day_counters').insert({
        'user_id': user.uid,
        'title': title,
        'target_date': '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
        'emoji': emoji,
        'color_hex': colorHex,
        'note': note,
      }).select().single();

      return DayCounterModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add day counter: $e');
    }
  }

  @override
  Future<DayCounterModel> updateDayCounter({
    required String id,
    required String title,
    required DateTime targetDate,
    String emoji = '❤️',
    String colorHex = 'FFD32F2F',
    String? note,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('day_counters').update({
        'title': title,
        'target_date': '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
        'emoji': emoji,
        'color_hex': colorHex,
        'note': note,
      }).eq('id', id).eq('user_id', user.uid).select().single();

      return DayCounterModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update day counter: $e');
    }
  }

  @override
  Future<void> deleteDayCounter({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _supabaseClient
          .from('day_counters')
          .delete()
          .eq('id', id)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete day counter: $e');
    }
  }

  // ─── Finance ────────────────────────────────────────────────────────────────

  @override
  Future<List<TransactionModel>> getTransactions({
    required int month,
    required int year,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final response = await _supabaseClient
          .from('transactions')
          .select('*, category:finance_categories!transactions_category_id_fkey(name, icon, color)')
          .eq('user_id', user.uid)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lt('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return response.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get transactions: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction({
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('transactions').insert({
        'user_id': user.uid,
        'category_id': categoryId,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'amount': amount,
        'note': note,
        'date': date.toIso8601String().split('T')[0],
      }).select('*, category:finance_categories!transactions_category_id_fkey(name, icon, color)').single();

      return TransactionModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('transactions').update({
        'category_id': categoryId,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'amount': amount,
        'note': note,
        'date': date.toIso8601String().split('T')[0],
      }).eq('id', id).eq('user_id', user.uid)
        .select('*, category:finance_categories!transactions_category_id_fkey(name, icon, color)')
        .single();

      return TransactionModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _supabaseClient
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<FinanceCategoryModel>> getFinanceCategories() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('finance_categories')
          .select()
          .or('is_default.eq.true,user_id.eq.${user.uid}')
          .order('is_default', ascending: false)
          .order('name');

      return response.map((json) => FinanceCategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get finance categories: $e');
    }
  }

  @override
  Future<FinanceCategoryModel> addFinanceCategory({
    required String name,
    required String icon,
    required String color,
    required TransactionType type,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('finance_categories').insert({
        'user_id': user.uid,
        'name': name,
        'icon': icon,
        'color': color,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'is_default': false,
      }).select().single();

      return FinanceCategoryModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add finance category: $e');
    }
  }

  @override
  Future<List<BudgetModel>> getBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('budgets')
          .select('*, category:finance_categories!budgets_category_id_fkey(name, icon, color)')
          .eq('user_id', user.uid)
          .eq('month', month)
          .eq('year', year);

      // Tính spent cho mỗi budget
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final transactions = await _supabaseClient
          .from('transactions')
          .select('category_id, amount')
          .eq('user_id', user.uid)
          .eq('type', 'expense')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lt('date', endDate.toIso8601String().split('T')[0]);

      // Group spending by category
      final spentMap = <String, int>{};
      for (final t in transactions) {
        final catId = t['category_id'] as String;
        spentMap[catId] = (spentMap[catId] ?? 0) + (t['amount'] as int);
      }

      return response.map((json) {
        final catId = json['category_id'] as String;
        final category = json['category'] as Map<String, dynamic>?;
        return BudgetModel(
          id: json['id'] as String,
          userId: json['user_id'] as String,
          categoryId: catId,
          amount: json['amount'] as int,
          month: json['month'] as int,
          year: json['year'] as int,
          createdAt: DateTime.parse(json['created_at'] as String),
          categoryName: category?['name'] as String?,
          categoryIcon: category?['icon'] as String?,
          categoryColor: category?['color'] as String?,
          spent: spentMap[catId] ?? 0,
        );
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get budgets: $e');
    }
  }

  @override
  Future<BudgetModel> setBudget({
    required String categoryId,
    required int amount,
    required int month,
    required int year,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('budgets').upsert({
        'user_id': user.uid,
        'category_id': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
      }, onConflict: 'user_id,category_id,month,year')
        .select('*, category:finance_categories!budgets_category_id_fkey(name, icon, color)')
        .single();

      return BudgetModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to set budget: $e');
    }
  }

  @override
  Future<FinanceOverview> getFinanceOverview({
    required int month,
    required int year,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final response = await _supabaseClient
          .from('transactions')
          .select('type, amount, category_id, category:finance_categories!transactions_category_id_fkey(name, icon, color)')
          .eq('user_id', user.uid)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lt('date', endDate.toIso8601String().split('T')[0]);

      int totalIncome = 0;
      int totalExpense = 0;
      final spendingMap = <String, _CategoryAccumulator>{};

      for (final row in response) {
        final type = row['type'] as String;
        final amount = row['amount'] as int;
        final catId = row['category_id'] as String;
        final cat = row['category'] as Map<String, dynamic>?;

        if (type == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
          final acc = spendingMap.putIfAbsent(
            catId,
            () => _CategoryAccumulator(
              id: catId,
              name: cat?['name'] as String? ?? '',
              icon: cat?['icon'] as String? ?? '📦',
              color: cat?['color'] as String? ?? 'FF9E9E9E',
            ),
          );
          acc.amount += amount;
        }
      }

      final spendingByCategory = spendingMap.values
          .map((a) => CategorySpending(
                categoryId: a.id,
                categoryName: a.name,
                categoryIcon: a.icon,
                categoryColor: a.color,
                amount: a.amount,
              ))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      return FinanceOverview(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        spendingByCategory: spendingByCategory,
        month: month,
        year: year,
      );
    } catch (e) {
      throw ServerException('Failed to get finance overview: $e');
    }
  }

  // ─── Helper ─────────────────────────────────────────────────────────────────

  @override
  Future<String> getCurrentUid() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw ServerException('User not authenticated');
    return user.uid;
  }

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─── Wishes ─────────────────────────────────────────────────────────────────

  @override
  Future<List<WishModel>> getWishes() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('wishes')
          .select()
          .eq('user_id', user.uid)
          .order('created_at', ascending: false);

      return response.map((json) => WishModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get wishes: $e');
    }
  }

  @override
  Future<WishModel> addWish({
    required String title,
    String? description,
    String emoji = '⭐',
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _ensureUserExists();

      final response = await _supabaseClient.from('wishes').insert({
        'user_id': user.uid,
        'title': title,
        'description': description,
        'emoji': emoji,
      }).select().single();

      return WishModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add wish: $e');
    }
  }

  @override
  Future<WishModel> updateWish({
    required String id,
    required String title,
    String? description,
    String emoji = '⭐',
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('wishes').update({
        'title': title,
        'description': description,
        'emoji': emoji,
      }).eq('id', id).eq('user_id', user.uid).select().single();

      return WishModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update wish: $e');
    }
  }

  @override
  Future<WishModel> completeWish({required String id, String? completionNote}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('wishes').update({
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
        'completion_note': completionNote,
      }).eq('id', id).eq('user_id', user.uid).select().single();

      return WishModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to complete wish: $e');
    }
  }

  @override
  Future<WishModel> uncompleteWish({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('wishes').update({
        'is_completed': false,
        'completed_at': null,
        'completion_note': null,
      }).eq('id', id).eq('user_id', user.uid).select().single();

      return WishModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to uncomplete wish: $e');
    }
  }

  @override
  Future<void> deleteWish({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _supabaseClient
          .from('wishes')
          .delete()
          .eq('id', id)
          .eq('user_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete wish: $e');
    }
  }

  // ─── Q&A ────────────────────────────────────────────────────────────────────

  @override
  Future<List<QaAnswerModel>> getQaAnswersForDate({
    required String friendshipId,
    required DateTime date,
  }) async {
    try {
      final response = await _supabaseClient
          .from('qa_answers')
          .select()
          .eq('friendship_id', friendshipId)
          .eq('question_date', _dateStr(date));

      return response.map((json) => QaAnswerModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get Q&A answers: $e');
    }
  }

  @override
  Future<QaAnswerModel> submitQaAnswer({
    required String friendshipId,
    required int questionIndex,
    required DateTime questionDate,
    required String answerText,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('qa_answers').insert({
        'user_id': user.uid,
        'friendship_id': friendshipId,
        'question_index': questionIndex,
        'question_date': _dateStr(questionDate),
        'answer_text': answerText,
      }).select().single();

      return QaAnswerModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to submit Q&A answer: $e');
    }
  }

  @override
  Future<List<QaAnswerModel>> getQaAnswerHistory({required String friendshipId}) async {
    try {
      final response = await _supabaseClient
          .from('qa_answers')
          .select()
          .eq('friendship_id', friendshipId)
          .order('question_date', ascending: false)
          .limit(200);

      return response.map((json) => QaAnswerModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get Q&A history: $e');
    }
  }

  // ─── Love Letters ───────────────────────────────────────────────────────────

  @override
  Future<List<LoveLetterModel>> getSentLetters() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('love_letters')
          .select('*, recipient:users!love_letters_recipient_id_fkey(display_name, photo_url)')
          .eq('sender_id', user.uid)
          .order('created_at', ascending: false);

      return response.map((json) => LoveLetterModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get sent letters: $e');
    }
  }

  @override
  Future<List<LoveLetterModel>> getReceivedLetters() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient
          .from('love_letters')
          .select('*, sender:users!love_letters_sender_id_fkey(display_name, photo_url)')
          .eq('recipient_id', user.uid)
          .order('delivery_date', ascending: false);

      return response.map((json) => LoveLetterModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get received letters: $e');
    }
  }

  @override
  Future<LoveLetterModel> sendLoveLetter({
    required String recipientId,
    required String title,
    required String content,
    required DateTime deliveryDate,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _ensureUserExists();

      final response = await _supabaseClient.from('love_letters').insert({
        'sender_id': user.uid,
        'recipient_id': recipientId,
        'title': title,
        'content': content,
        'delivery_date': _dateStr(deliveryDate),
      }).select('*, recipient:users!love_letters_recipient_id_fkey(display_name, photo_url)').single();

      return LoveLetterModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to send love letter: $e');
    }
  }

  @override
  Future<LoveLetterModel> markLetterAsRead({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      final response = await _supabaseClient.from('love_letters').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', id).eq('recipient_id', user.uid).select().single();

      return LoveLetterModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to mark letter as read: $e');
    }
  }

  @override
  Future<void> deleteLoveLetter({required String id}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('User not authenticated');

      await _supabaseClient
          .from('love_letters')
          .delete()
          .eq('id', id)
          .eq('sender_id', user.uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete love letter: $e');
    }
  }
}

class _CategoryAccumulator {
  final String id;
  final String name;
  final String icon;
  final String color;
  int amount = 0;

  _CategoryAccumulator({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
