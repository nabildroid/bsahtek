import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/screens/filters.dart';

class InlineFilters extends StatelessWidget {
  const InlineFilters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<BagsQubit>().state.availableTags;
    final selectedTags = context.watch<BagsQubit>().state.selectedTags;

    // sort tags by selectedtags, so anyone that contains the selected tags become in first
    tags.sort((a, b) {
      final aContains = selectedTags.any((element) => a.contains(element));
      final bContains = selectedTags.any((element) => b.contains(element));

      if (aContains && !bContains) {
        return -1;
      } else if (!aContains && bContains) {
        return 1;
      } else {
        return 0;
      }
    });

    return SizedBox(
        height: 40,
        child: BlocBuilder<BagsQubit, BagsState>(builder: (context, state) {
          return ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              ...tags.map(
                (tag) => Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      textStyle: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                      // if selected put a green border
                      side: BorderSide(
                        color: selectedTags.contains(tag)
                            ? Colors.green.shade500
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    onPressed: () {
                      context.read<BagsQubit>().toggleTag(tag);
                    },
                    child: Text(
                      "try: $tag",
                    ),
                  ),
                ),
              )
            ],
          );
        }));
  }
}
