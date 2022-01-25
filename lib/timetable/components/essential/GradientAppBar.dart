export "../../../components/LowLevel/GradientAppBar.dart";

// import 'package:flutter/material.dart';
// import 'package:reaxios/timetable/extensions.dart';

// class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final Widget title;
//   final Widget? leading;
//   final double elevation;
//   final List<Color>? colors;
//   final Color? foregroundColor;
//   final List<Widget>? actions;
//   final bool automaticallyImplyLeading;
//   final double radius;
//   final PreferredSizeWidget? bottom;

//   // ignore: use_key_in_widget_constructors
//   const GradientAppBar({
//     Key? key,
//     required this.title,
//     this.leading,
//     this.elevation = 4.0,
//     this.colors,
//     this.foregroundColor,
//     this.actions,
//     this.automaticallyImplyLeading = true,
//     this.radius = 0,
//     this.bottom,
//   }) : super();

//   @override
//   Size get preferredSize {
//     return AppBar(
//       automaticallyImplyLeading: automaticallyImplyLeading,
//       leading: leading,
//       title: title,
//       elevation: elevation,
//       actions: actions,
//       bottom: bottom,
//     ).preferredSize;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyedSubtree(
//       key: key,
//       child: AppBar(
//         title: title,
//         leading: leading,
//         actions: actions,
//         elevation: elevation,
//         bottom: _buildBottom(context),
//         automaticallyImplyLeading: automaticallyImplyLeading,
//         foregroundColor: foregroundColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(radius),
//           ),
//         ),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//               bottom: Radius.circular(radius),
//             ),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: colors ??
//                   Theme.of(context).colorScheme.primary.toSlightGradient(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget? _buildBottom(BuildContext context) {
//     if (bottom == null) {
//       return null;
//     }
//     return bottom!;
//   }
// }
