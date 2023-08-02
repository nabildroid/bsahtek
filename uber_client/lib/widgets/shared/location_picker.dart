import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';

class LocationPicker extends StatelessWidget {
  final VoidCallback onTap;
  final bool isTransparent;
  const LocationPicker({
    super.key,
    required this.onTap,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentArea = context.watch<BagsQubit>().state.currentArea;

    return GestureDetector(
      onTap: currentArea == null ? null : onTap,
      child: AnimatedScale(
        duration: Duration(seconds: 1),
        scale: currentArea == null ? 2 : 1,
        curve: Curves.easeInExpo,
        child: AnimatedOpacity(
          duration: Duration(seconds: 1),
          curve: Curves.easeInExpo,
          opacity: currentArea == null ? 0 : 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: !isTransparent ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: !isTransparent
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(children: [
              const Icon(
                Icons.location_pin,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              if (currentArea != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          currentArea.name.length > 20
                              ? currentArea.name.substring(20)
                              : currentArea.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "within ${currentArea!.radius} km",
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
              const Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.green,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
