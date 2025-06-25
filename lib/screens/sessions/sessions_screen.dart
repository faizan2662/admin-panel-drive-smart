// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/session_provider.dart';
// import '../../models/confirmed_session_model.dart';
// import '../../utils/theme.dart';
// import 'session_detail_dialog.dart';
//
// class SessionsScreen extends StatefulWidget {
//   const SessionsScreen({super.key});
//
//   @override
//   State<SessionsScreen> createState() => _SessionsScreenState();
// }
//
// class _SessionsScreenState extends State<SessionsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<SessionProvider>().fetchSessions();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Training Sessions',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     context.read<SessionProvider>().fetchSessions();
//                   },
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Refresh'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primaryBlue,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//
//             // Search and Filter Row
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search sessions...',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     onChanged: (value) {
//                       context.read<SessionProvider>().setSearchQuery(value);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Consumer<SessionProvider>(
//                     builder: (context, provider, _) {
//                       return DropdownButtonFormField<String>(
//                         value: provider.statusFilter,
//                         decoration: InputDecoration(
//                           labelText: 'Filter by Status',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: 'All Status', child: Text('All Status')),
//                           DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
//                           DropdownMenuItem(value: 'completed', child: Text('Completed')),
//                           DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
//                         ],
//                         onChanged: (value) {
//                           if (value != null) {
//                             provider.setStatusFilter(value);
//                           }
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//
//             // Sessions List
//             Expanded(
//               child: Consumer<SessionProvider>(
//                 builder: (context, provider, _) {
//                   if (provider.isLoading) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//
//                   final sessions = provider.filteredSessionDetails;
//
//                   if (sessions.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.event_note,
//                             size: 64,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'No sessions found',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   return ListView.builder(
//                     itemCount: sessions.length,
//                     itemBuilder: (context, index) {
//                       final session = sessions[index];
//                       return _buildSessionCard(session);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSessionCard(SessionDetail session) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           showDialog(
//             context: context,
//             builder: (context) => SessionDetailDialog(session: session),
//           );
//         },
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.event,
//                         color: AppTheme.primaryBlue,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${session.date} at ${session.time}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       _buildBookingStatusChip(session.isBooked),
//                       const SizedBox(width: 8),
//                       if (session.status != null)
//                         _buildStatusChip(session.status!),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//
//               // Participants Info
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildInfoItem(
//                       Icons.person,
//                       'Trainee',
//                       session.traineeName ?? 'N/A',
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildInfoItem(
//                       Icons.person_outline,
//                       'Trainer',
//                       session.trainerName ?? 'N/A',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//
//               // Amount and Created Date
//               Row(
//                 children: [
//                   if (session.totalAmount != null)
//                     Expanded(
//                       child: _buildInfoItem(
//                         Icons.attach_money,
//                         'Amount',
//                         '\$${session.totalAmount}',
//                       ),
//                     ),
//                   Expanded(
//                     child: _buildInfoItem(
//                       Icons.access_time,
//                       'Created',
//                       _formatDate(session.createdAt),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey[600]),
//         const SizedBox(width: 4),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black87,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
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
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
