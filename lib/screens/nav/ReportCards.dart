import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/ReportCard/ReportCard.dart';
import 'package:axios_api/entities/Structural/Structural.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Views/ReportCard.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:screenshot/screenshot.dart';

class ReportCardsPane extends StatefulWidget {
  ReportCardsPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _ReportCardsPaneState createState() => _ReportCardsPaneState();
}

class _ReportCardsPaneState extends State<ReportCardsPane> {
  bool loading = true;
  List<Period> periods = [];
  String selectedPeriod = '';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final ScrollController _controller = ScrollController();
  final screenshotController = ScreenshotController();
  bool isScreenshot = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 200)).then((_) {
      final cubit = context.read<AppCubit>();
      return Future.wait([
        cubit.loadStructural(),
        cubit.loadReportCards(),
      ]).then((_) {
        if (mounted) {
          setState(() {
            if (selectedPeriod.isEmpty && cubit.structural != null)
              selectedPeriod = cubit.periods.first.id;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<AppCubit>();
    await Future.wait([
      cubit.loadStructural(force: true),
      cubit.loadReportCards(force: true),
    ]);
    setState(() {
      if (selectedPeriod.isEmpty && cubit.structural != null)
        selectedPeriod = cubit.periods.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    final cubit = context.watch<AppCubit>();
    return RefreshIndicator(
      onRefresh: _onRefresh,
      key: _refreshIndicatorKey,
      child: () {
        if (cubit.structural != null)
          return Scaffold(
            persistentFooterButtons: [
              TextButton.icon(
                icon: Icon(Icons.save),
                label: Text(context.loc.translate("reportCard.saveToPhoto")),
                onPressed: isScreenshot ? null : takeScreenshot,
              ),
            ],
            body: buildOk(
              context,
              cubit.reportCards,
              cubit.periods,
              cubit.student!.studentUUID,
            ),
          );
        return LoadingUI();
      }(),
    );
  }

  takeScreenshot() async {
    setState(() {
      isScreenshot = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      screenshotController
          .capture(
        delay: Duration(milliseconds: 200),
      )
          .then((image) {
        setState(() {
          isScreenshot = false;
        });
        shareArbitraryData(
          data: image,
          filename: "${context.loc.translate("reportCard.filename")}.png",
          allowedExtensions: ["png"],
        );
      });
    });
  }

  Widget buildOk(
    BuildContext context,
    List<ReportCard> reportCards,
    List<Period> periods,
    String userID,
  ) {
    return SingleChildScrollView(
      controller: _controller,
      child: Screenshot(
        controller: screenshotController,
        child: Material(
          type: MaterialType.canvas,
          child: Center(
            child: MaxWidthContainer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                    .copyWith(top: 16),
                child: Column(
                  crossAxisAlignment: isScreenshot
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    if (isScreenshot) ...[
                      Text(
                        context.loc.translate("reportCard.period"),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(periods
                          .firstWhere((p) => p.id == selectedPeriod)
                          .desc),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        value: selectedPeriod.isEmpty
                            ? periods.first.id
                            : selectedPeriod,
                        // icon: const Icon(Icons.arrow_downward),
                        onChanged: (String? newValue) {
                          if (newValue == null) return;
                          setState(() {
                            selectedPeriod = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: context.loc.translate("reportCard.period"),
                        ),
                        items: periods
                            .toSet()
                            .map<DropdownMenuItem<String>?>((Period value) {
                              if (value.id.isEmpty) return null;
                              return DropdownMenuItem<String>(
                                value: value.id,
                                child: Text(value.desc),
                              );
                            })
                            .where((DropdownMenuItem<String>? item) =>
                                item != null)
                            .toList() as List<DropdownMenuItem<String>>,
                      ),
                    ],
                    if (selectedPeriod.isNotEmpty)
                      ReportCardComponent(
                        forceExpandAll: isScreenshot,
                        reportCard: reportCards.firstWhere(
                          (element) =>
                              element.periodUUID == selectedPeriod &&
                              element.studentUUID == userID,
                          orElse: () => ReportCard.empty(),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
