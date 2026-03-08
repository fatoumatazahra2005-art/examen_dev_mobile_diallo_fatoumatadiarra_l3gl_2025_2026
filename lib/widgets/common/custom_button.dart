import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = color ?? Theme.of(context).primaryColor;
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 48.0;

    final buttonChild = Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isLoading ? 0 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isOutlined ? mainColor : Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: isOutlined ? mainColor : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOutlined ? mainColor : Colors.white,
            ),
          ),
      ],
    );

    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStateProperty.resolveWith((states) => Size(buttonWidth, buttonHeight)),
      backgroundColor: WidgetStateProperty.resolveWith((states) =>
      isOutlined ? Colors.transparent : mainColor),
      side: WidgetStateProperty.resolveWith((states) =>
      isOutlined ? BorderSide(color: mainColor) : BorderSide.none),
      shape: WidgetStateProperty.resolveWith((states) =>
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );

    return isOutlined
        ? OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: buttonChild,
    )
        : ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: buttonChild,
    );
  }
}