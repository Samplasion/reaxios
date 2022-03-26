import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobx/mobx.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Views/ReportCard.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';

class ReportCardsPane extends StatefulWidget {
  ReportCardsPane({
    Key? key,
    required this.session,
    required this.store,
  }) : super(key: key);

  final Axios session;
  final RegistroStore store;

  @override
  _ReportCardsPaneState createState() => _ReportCardsPaneState();
}

class _ReportCardsPaneState extends State<ReportCardsPane> {
  bool loading = true;
  List<Period> periods = [];
  String selectedPeriod = '';
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    // initREData();
  }

  _onRefresh() async {
    final cubit = context.read<AppCubit>();
    try {
      await cubit.loadStructural();
      await cubit.loadReportCards();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    setState(() {
      if (selectedPeriod.isEmpty && cubit.structural != null)
        selectedPeriod = cubit.periods.first.id;
    });
  }

  _onLoad() async {
    final cubit = context.read<AppCubit>();
    try {
      await cubit.loadStructural();
      await cubit.loadReportCards();
      _refreshController.loadComplete();
    } catch (e) {
      _refreshController.loadFailed();
    }
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
    return SmartRefresher(
      onRefresh: _onRefresh,
      onLoading: _onLoad,
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      child: () {
        if (cubit.reportCards.isEmpty || cubit.structural == null)
          return LoadingUI();
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
