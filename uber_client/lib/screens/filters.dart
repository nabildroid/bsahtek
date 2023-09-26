import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';
import 'package:bsahtak/cubits/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/filter.dart';

class Filters extends StatefulWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  late Filter currentFilter;

  @override
  void initState() {
    final cubit = context.read<HomeCubit>();
    currentFilter = cubit.state.filter ?? Filter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final bagCubit = context.read<BagsQubit>();

    final allTags = bagCubit.state.availableTags;
    allTags.sort((a, b) => a.length - b.length);

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        child: Scaffold(
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close))
                ],
              ),
              Text(
                AppLocalizations.of(context)!.filter_title,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Divider(),
              ListTile(
                title: Text(AppLocalizations.of(context)!.filter_hide_soldout),
                trailing: Checkbox(
                  value: !currentFilter.showSoldOut,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      currentFilter = currentFilter.copyWith(showSoldOut: !(v));
                    });
                  },
                ),
              ),
              Divider(),
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppLocalizations.of(context)!.filter_type,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 200,
                            maxWidth: MediaQuery.of(context).size.width * 2,
                            minHeight: 50,
                            minWidth: MediaQuery.of(context).size.width * .5),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            ...allTags.map((tag) {
                              final selected = currentFilter.tags.contains(tag);
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                                  elevation: !selected ? 4 : 0,
                                  foregroundColor: !selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentFilter =
                                        currentFilter.toggleTag(tag);
                                  });
                                },
                                child: Text(tag),
                              );
                            })
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          bottomSheet: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        currentFilter = Filter();
                      });
                    },
                    child: Text(
                      "clear all",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .2,
                          vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      )),
                  onPressed: () {
                    if (currentFilter.isEmpty) {
                      cubit.setFilter(null);
                    } else {
                      cubit.setFilter(currentFilter);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
