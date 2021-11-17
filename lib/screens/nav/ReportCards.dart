import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/interfaces/Couple.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
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

  @override
  void initState() {
    super.initState();

    widget.store.fetchPeriods(widget.session);
    widget.store.fetchReportCards(widget.session);
    // initREData();
  }

  // initREData() async {
  //   await widget.session.login();
  //   Future.wait(<Future<dynamic>>[
  //     // widget.session.login().then((_) {
  //     widget.session.getReportCards(),
  //     /* .then((a) => setState(() => {
  //           reportCards = a;
  //         })), */
  //     widget.session
  //         .getStructural(), /* .then((s) => setState(() {
  //           periods = s.periods[0].periods;
  //           selectedPeriod = periods[0].desc;
  //         })),
  //     }), */
  //   ]).then((_) => setState(() => loading = false));
  // }

  @override
  Widget build(BuildContext context) {
    final initialData = [
      <ReportCard>[
        ReportCard(
          studentUUID: "",
          periodUUID: "",
          periodCode: "",
          period: "",
          result: "",
          rating: "",
          url: "",
          read: false,
          visible: false,
          subjects: [],
          dateRead: DateTime.now().add(Duration(days: 365)),
          canViewAbsences: false,
        ),
      ],
      <Period>[
        Period(
          id: "",
          desc: "",
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        )
      ]
    ];
    return FutureBuilder<List>(
      future: Future.wait([
        // Future.value([0, 1]),
        widget.store.reportCards ?? Future.value(initialData[0]),
        widget.store.periods ?? Future.value(initialData[1]),
      ]),
      initialData: initialData,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error!);
          if (snapshot.error! is Error)
            print((snapshot.error! as Error).stackTrace);
          return Text("${snapshot.error}");
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          if (selectedPeriod.isEmpty)
            selectedPeriod = (snapshot.requireData[1] as List<Period>)[0].desc;
          return buildOk(context, snapshot.requireData[0] as List<ReportCard>,
              snapshot.requireData[1] as List<Period>);
        }

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<ReportCard> reportCards,
      List<Period> periods) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              .copyWith(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPeriod,
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
                    .map<DropdownMenuItem<String>>((Period value) {
                  return DropdownMenuItem<String>(
                    value: value.desc,
                    child: Text(value.desc),
                  );
                }).toList(),
              ),
              ReportCardComponent(
                reportCard: reportCards.firstWhere(
                  (element) => element.period == selectedPeriod,
                  orElse: () => ReportCard.empty(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
