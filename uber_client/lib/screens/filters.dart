import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/bags_cubit.dart';

class Filters extends StatelessWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        width: double.infinity,
        child: BlocBuilder<BagsQubit, BagsState>(builder: (context, state) {
          return Column(
            children: [],
          );
        }));
  }
}
