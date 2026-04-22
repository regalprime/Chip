import 'dart:io';

import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/di/injection.dart';
import 'package:common_packages/presentation/blocs/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const LoadProfileEvent()),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _avatarFilePath;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _avatarFilePath = image.path);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<ProfileBloc>().add(UpdateProfileEvent(
          displayName: name,
          bio: _bioController.text.trim(),
          avatarFilePath: _avatarFilePath,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.saving) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                onPressed: _save,
                icon: const Icon(Icons.check),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thành công!')),
            );
            Navigator.pop(context);
          }
          if (state.status == ProfileStatus.error) {
            DSErrorDialog.show(context, message: state.errorMessage ?? 'Đã xảy ra lỗi');
          }
          if (state.status == ProfileStatus.loaded && !_initialized) {
            _nameController.text = state.user?.displayName ?? '';
            _bioController.text = state.user?.bio ?? '';
            _initialized = true;
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundImage: _avatarFilePath != null
                            ? FileImage(File(_avatarFilePath!))
                            : (user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null),
                        child: user?.photoUrl == null && _avatarFilePath == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.email != null)
                  Text(
                    user!.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên hiển thị',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Giới thiệu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Lưu thay đổi'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
