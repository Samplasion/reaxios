import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Views/ReportCard.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils.dart';

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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 200)).then((_) {
      final cubit = context.read<AppCubit>();
      return Future.wait([
        cubit.loadStructural(),
        cubit.loadReportCards(),
      ]).then((_) {
        setState(() {
          if (selectedPeriod.isEmpty && cubit.structural != null)
            selectedPeriod = cubit.periods.first.id;
        });
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
          return buildOk(context, cubit.reportCards, cubit.periods);
        return LoadingUI();
      }(),
    );
  }

  Widget buildOk(
    BuildContext context,
    List<ReportCard> reportCards,
    List<Period> periods,
  ) {
    return SingleChildScrollView(
      controller: _controller,
      child: Center(
        child: MaxWidthContainer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                .copyWith(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    labelText: context.locale.reportCard.period,
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
                      .where((DropdownMenuItem<String>? item) => item != null)
                      .toList() as List<DropdownMenuItem<String>>,
                ),
                if (selectedPeriod.isNotEmpty)
                  ReportCardComponent(
                    reportCard: reportCards.firstWhere(
                      (element) => element.periodUUID == selectedPeriod,
                      orElse: () => ReportCard.empty(),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
