// import 'package:flutter/material.dart';
// import '../models/session_model.dart';
// import '../utils/theme.dart';
//
// class SessionsCard extends StatelessWidget {
//   final List<SessionModel> upcomingSessions;
//
//   const SessionsCard({
//     super.key,
//     required this.upcomingSessions,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   color: AppTheme.primaryGreen,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Upcoming Sessions',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (upcomingSessions.isEmpty)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(32),
//                   child: Text(
//                     'No upcoming sessions',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               )
//             else
//               ...upcomingSessions.map((session) => _buildSessionItem(session)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSessionItem(SessionModel session) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[200]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${session.trainerName} → ${session.traineeName}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   session.timeString,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: session.statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               session.typeDisplayName,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: session.statusColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
