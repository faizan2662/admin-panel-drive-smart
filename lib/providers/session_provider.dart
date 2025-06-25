// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/confirmed_session_model.dart';
//
// class SessionProvider extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   List<ConfirmedSessionModel> _sessions = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   String _statusFilter = 'All Status';
//
//   List<ConfirmedSessionModel> get sessions => _sessions;
//   bool get isLoading => _isLoading;
//   String get searchQuery => _searchQuery;
//   String get statusFilter => _statusFilter;
//
//   List<SessionDetail> get allSessionDetails {
//     List<SessionDetail> allSessions = [];
//     for (var session in _sessions) {
//       allSessions.addAll(session.sessions);
//     }
//     return allSessions;
//   }
//
//   List<SessionDetail> get filteredSessionDetails {
//     List<SessionDetail> filtered = allSessionDetails;
//
//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((session) =>
//       session.traineeName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
//           session.trainerName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
//           session.date.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           session.time.toLowerCase().contains(_searchQuery.toLowerCase())
//       ).toList();
//     }
//
//     // Apply status filter
//     if (_statusFilter != 'All Status') {
//       filtered = filtered.where((session) =>
//       session.status?.toLowerCase() == _statusFilter.toLowerCase()
//       ).toList();
//     }
//
//     // Sort by date and time
//     filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
//
//     return filtered;
//   }
//
//   Future<void> fetchSessions() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       print('Fetching sessions from Firebase...');
//       final QuerySnapshot snapshot = await _firestore
//           .collection('confirmed_sessions')
//           .get();
//
//       print('Found ${snapshot.docs.length} session documents');
//
//       _sessions = [];
//       for (var doc in snapshot.docs) {
//         try {
//           final data = doc.data() as Map<String, dynamic>;
//           print('Processing session: ${doc.id}');
//           print('Session data: $data');
//
//           final session = ConfirmedSessionModel.fromMap(data, doc.id);
//           _sessions.add(session);
//           print('Successfully added session with ${session.sessions.length} individual sessions');
//         } catch (e) {
//           print('Error processing session ${doc.id}: $e');
//         }
//       }
//
//       // Sort by acceptedAt (newest first)
//       _sessions.sort((a, b) => b.acceptedAt.compareTo(a.acceptedAt));
//
//       print('Successfully loaded ${_sessions.length} confirmed sessions');
//     } catch (e) {
//       print('Error fetching sessions: $e');
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }
//
//   void setStatusFilter(String status) {
//     _statusFilter = status;
//     notifyListeners();
//   }
//
//   Future<bool> updateSessionStatus(String sessionId, int sessionIndex, String status) async {
//     try {
//       final sessionDoc = _sessions.firstWhere((s) => s.id == sessionId);
//       final updatedSessions = List<SessionDetail>.from(sessionDoc.sessions);
//
//       if (sessionIndex < updatedSessions.length) {
//         final updatedSession = SessionDetail(
//           createdAt: updatedSessions[sessionIndex].createdAt,
//           date: updatedSessions[sessionIndex].date,
//           dateTime: updatedSessions[sessionIndex].dateTime,
//           isBooked: updatedSessions[sessionIndex].isBooked,
//           time: updatedSessions[sessionIndex].time,
//           status: status,
//           totalAmount: updatedSessions[sessionIndex].totalAmount,
//           traineeId: updatedSessions[sessionIndex].traineeId,
//           traineeName: updatedSessions[sessionIndex].traineeName,
//           trainerId: updatedSessions[sessionIndex].trainerId,
//           trainerName: updatedSessions[sessionIndex].trainerName,
//         );
//
//         updatedSessions[sessionIndex] = updatedSession;
//
//         await _firestore
//             .collection('confirmed_sessions')
//             .doc(sessionId)
//             .update({
//           'sessions': updatedSessions.map((s) => s.toMap()).toList(),
//         });
//
//         // Refresh sessions after update
//         await fetchSessions();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Error updating session status: $e');
//       return false;
//     }
//   }
//
//   Future<bool> deleteSession(String sessionId) async {
//     try {
//       await _firestore
//           .collection('confirmed_sessions')
//           .doc(sessionId)
//           .delete();
//
//       // Remove from local data
//       _sessions.removeWhere((session) => session.id == sessionId);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       print('Error deleting session: $e');
//       return false;
//     }
//   }
//
//   Future<bool> updateSession(String sessionId, Map<String, dynamic> updates) async {
//     try {
//       await _firestore
//           .collection('confirmed_sessions')
//           .doc(sessionId)
//           .update(updates);
//
//       // Refresh sessions after update
//       await fetchSessions();
//       return true;
//     } catch (e) {
//       print('Error updating session: $e');
//       return false;
//     }
//   }
// }
