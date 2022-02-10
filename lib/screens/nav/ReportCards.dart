import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Views/ReportCard.dart';
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

    widget.store.fetchPeriods(widget.session);
    widget.store.fetchReportCards(widget.session);
    // initREData();
  }

  _onRefresh() async {
    try {
      await widget.store.fetchPeriods(widget.session);
      await widget.store.fetchReportCards(widget.session);
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    setState(() {
      if (selectedPeriod.isEmpty &&
          widget.store.periods != null &&
          widget.store.periods!.status == FutureStatus.fulfilled)
        selectedPeriod = widget.store.periods!.value!.first.id;
    });
  }

  _onLoad() async {
    try {
      await widget.store.fetchPeriods(widget.session);
      await widget.store.fetchReportCards(widget.session);
      _refreshController.loadComplete();
    } catch (e) {
      _refreshController.loadFailed();
    }
    setState(() {
      if (selectedPeriod.isEmpty &&
          widget.store.periods != null &&
          widget.store.periods!.status == FutureStatus.fulfilled)
        selectedPeriod = widget.store.periods!.value!.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return SmartRefresher(
      onRefresh: _onRefresh,
      onLoading: _onLoad,
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      child: () {
        if (widget.store.reportCards == null || widget.store.periods == null)
          return LoadingUI();
        if (widget.store.reportCards!.value != null &&
            widget.store.periods!.value != null &&
            (widget.store.reportCards!.status == FutureStatus.fulfilled ||
                widget.store.periods!.status == FutureStatus.fulfilled))
          return buildOk(context, widget.store.reportCards!.value!,
              widget.store.periods!.value!);
        if (widget.store.reportCards!.status == FutureStatus.rejected ||
            widget.store.periods!.status == FutureStatus.rejected)
          return Text("${widget.store.reportCards!.error}");
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
