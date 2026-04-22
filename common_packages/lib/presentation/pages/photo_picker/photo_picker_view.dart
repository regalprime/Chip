import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/presentation/blocs/photo/photo_bloc.dart';
import 'package:common_packages/presentation/pages/share/share_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhotoPickerView extends StatelessWidget {
  const PhotoPickerView({super.key});

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (image == null || !context.mounted) return;

    context.read<PhotoBloc>().add(UploadPhotoEvent(image.path));
  }

  void _showPhotoMenu(BuildContext context, String photoId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ với bạn bè'),
              onTap: () {
                Navigator.pop(context);
                ShareDialog.show(context, itemId: photoId, itemType: 'photo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xoá ảnh', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, [photoId]);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, List<String> photoIds) {
    final count = photoIds.length;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá $count ảnh không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PhotoBloc>().add(DeletePhotosEvent(photoIds));
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoBloc, PhotoState>(
      listener: (context, state) {
        if (state.status == PhotoStatus.error) {
          DSErrorDialog.show(context, message: state.errorMessage ?? 'Đã xảy ra lỗi');
        }
      },
      child: BlocBuilder<PhotoBloc, PhotoState>(
        builder: (context, state) {
          return Scaffold(
            appBar: state.isSelectionMode
                ? AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context
                          .read<PhotoBloc>()
                          .add(const ClearSelectionEvent()),
                    ),
                    title: Text('Đã chọn ${state.selectedPhotoIds.length}'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: state.selectedPhotoIds.isEmpty
                            ? null
                            : () => _confirmDelete(
                                  context,
                                  state.selectedPhotoIds.toList(),
                                ),
                      ),
                    ],
                  )
                : null,
            body: _buildBody(context, state),
            floatingActionButton:
                state.isSelectionMode ? null : _buildFab(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PhotoState state) {
    return switch (state.status) {
      PhotoStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      PhotoStatus.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  final msg = state.errorMessage ?? 'Đã xảy ra lỗi';
                  Clipboard.setData(ClipboardData(text: msg));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã copy lỗi')),
                  );
                },
                child: Text(
                  state.errorMessage ?? 'Đã xảy ra lỗi',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    context.read<PhotoBloc>().add(const LoadPhotosEvent()),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      _ => state.photos.isEmpty
          ? const Center(child: Text('Chưa có ảnh nào'))
          : Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.photos.length,
                  itemBuilder: (context, index) {
                    final photo = state.photos[index];
                    final isSelected =
                        state.selectedPhotoIds.contains(photo.id);
                    return GestureDetector(
                      onTap: () {
                        if (state.isSelectionMode) {
                          context
                              .read<PhotoBloc>()
                              .add(TogglePhotoSelectionEvent(photo.id));
                        } else {
                          _showPhotoMenu(context, photo.id);
                        }
                      },
                      onLongPress: () {
                        if (!state.isSelectionMode) {
                          context
                              .read<PhotoBloc>()
                              .add(TogglePhotoSelectionEvent(photo.id));
                        }
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photo.url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          if (state.isSelectionMode)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.black38,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check
                                        : Icons.circle_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          if (isSelected)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                if (state.status == PhotoStatus.deleting)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    };
  }

  Widget? _buildFab(BuildContext context, PhotoState state) {
    if (state.status == PhotoStatus.uploading) {
      return const FloatingActionButton(
        onPressed: null,
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return FloatingActionButton(
      onPressed: () => _pickAndUploadPhoto(context),
      child: Icon(PhosphorIcons.image()),
    );
  }
}
