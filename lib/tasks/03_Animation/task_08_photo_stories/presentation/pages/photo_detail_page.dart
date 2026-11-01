

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/pixabay_photo.dart';

class PhotoDetailPage extends StatefulWidget {
  const PhotoDetailPage({
    super.key,
    required this.photo,
  });

  final PixabayPhoto photo;

  @override
  State<PhotoDetailPage> createState() =>
      _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  double dragY = 0;

  static const orange = Color(0xFFA33900);

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;

    final scale =
        (1 - dragY / 1000).clamp(.82, 1.0).toDouble();

    final opacity =
        (1 - dragY / 380).clamp(.45, 1.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F8),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        title: const Text(
          'Hero Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          _dragHint(),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (details.delta.dy <= 0 && dragY <= 0) return;

              setState(() {
                dragY = (dragY + details.delta.dy)
                    .clamp(0, 240)
                    .toDouble();
              });
            },
            onVerticalDragEnd: (_) {
              if (dragY >= 110) {
                Navigator.pop(context);
              } else {
                setState(() {
                  dragY = 0;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(0, dragY * .45),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: opacity,
                  child: _heroImage(photo),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photographer(photo),

                const SizedBox(height: 22),

                const Text(
                  'TỪ KHÓA PHÂN LOẠI',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .8,
                  ),
                ),

                const SizedBox(height: 8),

                _tags(photo),

                const SizedBox(height: 22),

                _stats(photo),

                const SizedBox(height: 22),

                _imageInfo(photo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dragHint() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 9),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            child: Divider(
              thickness: 5,
              color: Color(0xFFE2BFB2),
            ),
          ),
          Text(
            '↓ KÉO XUỐNG ĐỂ ĐÓNG ẢNH',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroImage(PixabayPhoto photo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Hero(
        tag: 'pixabay_${photo.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: .8,
                child: CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) {
                    return Container(
                      color: const Color(0xFFE8E8E7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: orange,
                        ),
                      ),
                    );
                  },
                  errorWidget: (_, _, _) {
                    return const Center(
                      child: Icon(Icons.broken_image),
                    );
                  },
                ),
              ),

              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33000000),
                        Colors.transparent,
                        Color(0x99000000),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 13,
                left: 13,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: Color(0xFFFD761A),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'PIXABAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,
                child: Text(
                  '${photo.imageWidth} × ${photo.imageHeight} px',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photographer(PixabayPhoto photo) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE8E8E7),
            backgroundImage: photo.userImageUrl.isEmpty
                ? null
                : NetworkImage(photo.userImageUrl),
            child: photo.userImageUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.user,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Photographer • Pixabay',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.photo_camera_outlined,
            color: orange,
          ),
        ],
      ),
    );
  }

  Widget _tags(PixabayPhoto photo) {
    if (photo.tags.isEmpty) {
      return const Text(
        'Không có từ khóa.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: photo.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEED),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _stats(PixabayPhoto photo) {
    return Row(
      children: [
        Expanded(
          child: _stat(
            Icons.visibility_outlined,
            _compact(photo.views),
            'Lượt xem',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _stat(
            Icons.favorite_outline,
            _compact(photo.likes),
            'Yêu thích',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _stat(
            Icons.download_outlined,
            _compact(photo.downloads),
            'Lượt tải',
          ),
        ),
      ],
    );
  }

  Widget _stat(
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: orange, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageInfo(PixabayPhoto photo) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(
            'Loại ảnh',
            photo.type,
          ),
          const Divider(height: 20),
          _infoRow(
            'Kích thước',
            '${photo.imageWidth} × ${photo.imageHeight}',
          ),
          const Divider(height: 20),
          _infoRow(
            'Bình luận',
            '${photo.comments}',
          ),
          const Divider(height: 20),
          const _SourceRow(),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _compact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return '$value';
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: Color(0xFFA33900),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Metadata được lấy trực tiếp từ Pixabay API',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}