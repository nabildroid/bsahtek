import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_client/cubits/bags_cubit.dart';

class LocationPicker extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const LocationPicker({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BagsQubit, BagsState>(builder: (context, state) {
      return GestureDetector(
        onTap: state.currentArea == null ? null : onTap,
        child: AnimatedScale(
          duration: Duration(seconds: 1),
          scale: state.currentArea == null ? 2 : 1,
          curve: Curves.easeInExpo,
          child: AnimatedOpacity(
            duration: Duration(seconds: 1),
            curve: Curves.easeInExpo,
            opacity: state.currentArea == null ? 0 : 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(children: [
                const Icon(
                  Icons.location_pin,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                if (state.currentArea != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.currentArea!.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "within ${state.currentArea!.radius} km",
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
    });
  }
}
