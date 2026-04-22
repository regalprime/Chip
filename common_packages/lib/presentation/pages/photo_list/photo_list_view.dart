import 'package:common_packages/presentation/blocs/photo/photo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoListView extends StatelessWidget {
  const PhotoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoBloc, PhotoState>(
      builder: (context, state) {
        return switch (state.status) {
          PhotoStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
          PhotoStatus.error => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Đã xảy ra lỗi'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.read<PhotoBloc>().add(const LoadPhotosEvent()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          _ => state.photos.isEmpty
              ? const Center(child: Text('Chưa có ảnh nào'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.photos.length,
                  itemBuilder: (context, index) {
                    final photo = state.photos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photo.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
        };
      },
    );
  }
}
