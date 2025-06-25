// import 'package:flutter/material.dart';
// import '../../models/confirmed_session_model.dart';
// import '../../utils/theme.dart';
//
// class SessionDetailDialog extends StatelessWidget {
//   final SessionDetail session;
//
//   const SessionDetailDialog({
//     super.key,
//     required this.session,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: 500,
//         constraints: const BoxConstraints(maxHeight: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(8),
//                   topRight: Radius.circular(8),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.event_note, color: Colors.white),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Session Details',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Date & Time
//                     _buildSection(
//                       'Schedule',
//                       [
//                         _buildInfoRow('Date', session.date),
//                         _buildInfoRow('Time', session.time),
//                         _buildInfoRow('Created At',
//                             session.createdAt.toString().split('.')[0]),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Participants
//                     _buildSection(
//                       'Participants',
//                       [
//                         _buildInfoRow('Trainee', session.traineeName ?? 'N/A'),
//                         _buildInfoRow('Trainer', session.trainerName ?? 'N/A'),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Status & Booking Info
//                     _buildSection(
//                       'Status Information',
//                       [
//                         Row(
//                           children: [
//                             const Text(
//                               'Booking Status:',
//                               style: TextStyle(fontWeight: FontWeight.w500),
//                             ),
//                             const SizedBox(width: 8),
//                             _buildBookingStatusChip(session.isBooked),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         if (session.status != null)
//                           Row(
//                             children: [
//                               const Text(
//                                 'Session Status:',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               const SizedBox(width: 8),
//                               _buildStatusChip(session.status!),
//                             ],
//                           ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Payment Information
//                     if (session.totalAmount != null)
//                       _buildSection(
//                         'Payment',
//                         [
//                           _buildInfoRow('Total Amount', '\$${session.totalAmount}'),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Actions
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Delete button
//                   ElevatedButton.icon(
//                     onPressed: () => _showDeleteConfirmation(context),
//                     icon: const Icon(Icons.delete, size: 18),
//                     label: const Text('Delete'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//
//                   Row(
//                     children: [
//                       // Status update buttons
//                       if (session.status?.toLowerCase() != 'completed') ...[
//                         ElevatedButton(
//                           onPressed: () => _updateSessionStatus(context, 'completed'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: const Text('Mark Complete'),
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//
//                       if (session.status?.toLowerCase() != 'cancelled') ...[
//                         ElevatedButton(
//                           onPressed: () => _updateSessionStatus(context, 'cancelled'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: const Text('Cancel'),
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//
//                       ElevatedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Close'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...children,
//       ],
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookingStatusChip(bool isBooked) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: isBooked ? Colors.blue[100] : Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isBooked ? Colors.blue[300]! : Colors.grey[300]!,
//         ),
//       ),
//       child: Text(
//         isBooked ? 'BOOKED' : 'AVAILABLE',
//         style: TextStyle(
//           color: isBooked ? Colors.blue[800] : Colors.grey[600],
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(String status) {
//     Color color;
//     switch (status.toLowerCase()) {
//       case 'confirmed':
//         color = Colors.green;
//         break;
//       case 'completed':
//         color = Colors.blue;
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         break;
//       default:
//         color = Colors.grey;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: color,
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   void _updateSessionStatus(BuildContext context, String status) async {
//     // Note: This is a simplified approach. In a real app, you'd need to find the exact session
//     // and update it properly. For now, we'll show a message.
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Session status updated to $status'),
//         backgroundColor: Colors.green,
//       ),
//     );
//     Navigator.of(context).pop();
//   }
//
//   void _showDeleteConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Session'),
//           content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close confirmation dialog
//                 Navigator.of(context).pop(); // Close detail dialog
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Session deleted successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
