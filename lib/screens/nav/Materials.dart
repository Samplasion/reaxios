import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Views/MaterialTeacherView.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class MaterialsPane extends StatefulWidget {
  MaterialsPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _MaterialsPaneState createState() => _MaterialsPaneState();
}

class _MaterialsPaneState extends State<MaterialsPane> {
  String _selectedTeacher = "";

  @override
  void initState() {
    super.initState();
  }

  MaterialTeacherData getSelectedMaterial(List<MaterialTeacherData> materials) {
    return materials.firstWhere((element) => element.name == _selectedTeacher,
        orElse: () => MaterialTeacherData.empty());
  }

  String getCount(int count) {
    return Intl.plural(
      count,
      zero: context.loc
          .translate("teachingMaterials.foldersZero")
          .format([count]),
      one:
          context.loc.translate("teachingMaterials.foldersOne").format([count]),
      two:
          context.loc.translate("teachingMaterials.foldersTwo").format([count]),
      few:
          context.loc.translate("teachingMaterials.foldersFew").format([count]),
      many: context.loc
          .translate("teachingMaterials.foldersMany")
          .format([count]),
      other: context.loc
          .translate("teachingMaterials.foldersOther")
          .format([count]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AppCubit>();
    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (context, state) {
        final _materials = cubit.materials;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: _materials.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) => ListView(
                    children: [
                      Container(
                        height: constraints.maxHeight,
                        child: EmptyUI(
                          icon: Icons.error_outline,
                          text:
                              context.loc.translate("teachingMaterials.noData"),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: MaxWidthContainer(
                        child: CardListItem(
                          leading: GradientCircleAvatar(
                            color: Utils.getColorFromString(
                                _materials[index].name),
                            child: Text(
                              _materials[index].name.substring(0, 1),
                            ),
                          ),
                          title: _materials[index].name,
                          subtitle: Text(_materials[index].subjects),
                          details: Text(
                            getCount(_materials[index].folders.length),
                          ),
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MaterialTeacherView(_materials[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ).padding(
                      horizontal: 16,
                      top: index == 0 ? 8 : 0,
                      bottom: index == _materials.length - 1 ? 8 : 0,
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    await context.read<AppCubit>().loadMaterials(force: true);
  }
}
