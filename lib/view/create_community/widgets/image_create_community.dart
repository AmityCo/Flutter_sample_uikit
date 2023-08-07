import 'package:flutter/material.dart';

import '../../../constans/app_text_style.dart';

class ImageCreateCommunity extends StatelessWidget {
  const ImageCreateCommunity({
    super.key,
    this.image,
    this.onPressed,
  });
  
  final ImageProvider? image;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.black45,
        image: image != null
            ? DecorationImage(
                image: image!,
                fit: BoxFit.fitWidth,
              )
            : null,
      ),
      child: Center(
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  'Upload image',
                  style: AppTextStyle.header1.copyWith(
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
