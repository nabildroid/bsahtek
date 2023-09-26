import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';

import '../home/view_mode.dart';

class LocationPicker extends StatelessWidget {
  final VoidCallback onTap;
  final bool isTransparent;
  final Widget? bottomBar;
  const LocationPicker({
    super.key,
    required this.onTap,
    this.isTransparent = false,
    this.bottomBar,
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
          child: Hero(
            tag: "LocationPicker",
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
              child: Column(
                children: [
                  Row(children: [
                    Icon(
                      Icons.location_pin,
                      color: Theme.of(context).colorScheme.tertiary,
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
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!
                                  .home_location_within(currentArea.radius),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ]),
                  if (bottomBar != null) ...[
                    SizedBox(height: 8),
                    bottomBar!,
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
