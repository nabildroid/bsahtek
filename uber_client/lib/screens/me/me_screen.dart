import 'package:bsahtak/screens/me/privacy.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bsahtak/cubits/home_cubit.dart';
import 'package:bsahtak/screens/me/privacy.dart';
import 'package:bsahtak/screens/me/term.dart';

import '../../cubits/app_cubit.dart';
import '../../repositories/cache.dart';
import '../../utils/constants.dart';
import '../../utils/utils.dart';
import 'fqa.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Cache.lastUpdatePrevOrders;

    final prevOrders = context.watch<HomeCubit>().state.prevOrders;
    prevOrders.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

    final savedBags = prevOrders
        .where((element) => !element.expired && !element.inProgress)
        .toList();

    final app = context.read<AppCubit>().state;

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.me_title,
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(app.client!.photo),
            ),
            SizedBox(width: 10),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(.8),
                padding: EdgeInsets.only(top: 80, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: prevOrders.length,
                        itemBuilder: (BuildContext context, int index) {
                          final order = prevOrders[index];
                          return Container(
                              width: MediaQuery.of(context).size.width * .7,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.95),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.createdAt
                                            .toString()
                                            .split(" ")[0],
                                      ),
                                      Opacity(
                                          opacity: .6,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiary
                                                          .withOpacity(.3),
                                                      BlendMode.srcOver),
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      order.bagImage,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 7),
                                              Text(Utils.splitTranslation(
                                                  order.sellerName ??
                                                      order.bagName,
                                                  context))
                                            ],
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 26,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: order.bagPrice + "dz",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " ×${order.quantity}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "#${order.id.substring(0, 7)}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: "monospace",
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        order.id == Constants.notActiveOrderID
                                            ? AppLocalizations.of(context)!
                                                .me_status_pending
                                            : order.expired
                                                ? AppLocalizations.of(context)!
                                                    .me_status_expired
                                                : order.inProgress
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .me_status_progress
                                                    : order.isPickup
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .me_status_pickup
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .me_status_delivred,
                                        style: TextStyle(
                                          color: order.expired
                                              ? Colors.red.shade600
                                              : order.inProgress
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(0, -20),
                child: Row(
                  children: [
                    Status(
                      icon: Icons.money_outlined,
                      label: savedBags
                              .fold(0.0, (p, n) => p + double.parse(n.bagPrice))
                              .toString() +
                          " dz",
                    ),
                    Status(
                      icon: Icons.shopping_basket_outlined,
                      label: savedBags.length.toString(),
                    ),
                    Status(
                      icon: Icons.co2,
                      label: "${savedBags.length * 2.33} KG CO2",
                    )
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(AppLocalizations.of(context)!.me_settings),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => context.push("/me/settings"),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.me_terms),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => TermsAndConditionsPage()),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.me_privacy),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => PrivacyScreen()),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.me_fqa),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => FQAScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Status extends StatelessWidget {
  final String label;
  final IconData icon;

  const Status({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white),
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
