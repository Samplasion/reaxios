import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/utils.dart';

import '../../api/entities/Curriculum/curriculum.dart';
import '../../components/LowLevel/GradientCircleAvatar.dart';
import '../../components/LowLevel/Loading.dart';
import '../../components/Utilities/ResourcefulCardListItem.dart';
import '../../cubit/app_cubit.dart';

class CurriculumPane extends StatelessWidget {
  const CurriculumPane({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        if (state.curricula != null)
          return buildOk(context, state.curricula!.toList());

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Curriculum> curricula) {
    return ListView.builder(
      itemBuilder: (context, index) =>
          _curriculumBuilder(context, curricula[index]),
      itemCount: curricula.length,
    );
  }

  Widget _curriculumBuilder(BuildContext context, Curriculum curriculum) {
    final scheme = Theme.of(context).colorScheme;
    AlertColor color;

    switch (curriculum.outcomeType) {
      case CurriculumOutcome.admitted:
        color = AlertColor.fromMaterialColor(
          context,
          Colors.green.harmonizeWith(context),
        );
        break;
      case CurriculumOutcome.suspended:
        color = AlertColor.fromMaterialColor(
          context,
          Colors.orange.harmonizeWith(context),
        );
        break;
      case CurriculumOutcome.heldBack:
        color = AlertColor.fromMaterialColor(
          context,
          Colors.red.harmonizeWith(context),
        );
        break;
      case CurriculumOutcome.noData:
        color = AlertColor.fromMaterialColor(
          context,
          Colors.grey.harmonizeWith(context),
        );
        break;
    }

    return ResourcefulCardListItem(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: GradientCircleAvatar(
          color: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          child: Icon(Icons.school),
        ),
      ),
      title:
          "${curriculum.classYear}${curriculum.section} ${curriculum.course}",
      subtitle: Text((curriculum.outcome ?? "")
          .or(context.loc.translate("curriculum.noOutcome"))),
      location: Text(curriculum.school),
      date: Text(context.loc.translate(
        "curriculum.schoolYear",
        {'year': curriculum.schoolYear},
      )),
      description: Chip(
        label: Text(
          context.loc.translate(
            "curriculum.outcomes.${curriculum.outcomeType.name}",
            {"credits": curriculum.credits.or("0")},
          ),
          style: TextStyle(color: color.foreground),
        ),
        backgroundColor: color.background,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}