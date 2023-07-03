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
    return SizedBox(
        height: 40,
        child: BlocBuilder<BagsQubit, BagsState>(builder: (context, state) {
          return ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              ...List.generate(
                10,
                (index) => Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      textStyle: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(builder: (ctx) {
                      //   return Filters();
                      // }));
                    },
                    child: Text(
                      "try: Hide sold-out",
                    ),
                  ),
                ),
              )
            ],
          );
        }));
  }
}
