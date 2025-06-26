import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _statusFilter = 'All Status';

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  List<BookingModel> get filteredBookings {
    List<BookingModel> filtered = _bookings;

    // Apply search filter only
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((booking) =>
      booking.traineeName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          booking.trainerName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          booking.requestType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.selectedPlans.any((plan) => plan.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          booking.bookedBy.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Sort by newest first
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Fetching bookings from Firebase...');
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .get();

      print('Found ${snapshot.docs.length} booking documents');

      _bookings = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('Processing booking: ${doc.id}');
          print('Booking data: $data'); // Debug log

          final booking = BookingModel.fromMap(data, doc.id);
          _bookings.add(booking);
          print('Successfully added booking with status: ${booking.status}, amount: ${booking.totalAmount}');
        } catch (e) {
          print('Error processing booking ${doc.id}: $e');
          print('Booking data: ${doc.data()}'); // Debug problematic data
        }
      }

      // Sort by timestamp (newest first)
      _bookings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('Successfully loaded ${_bookings.length} bookings');
    } catch (e) {
      print('Error fetching bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<bool> deleteBooking(String bookingId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .delete();

      // Remove from local data
      _bookings.removeWhere((booking) => booking.id == bookingId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting booking: $e');
      return false;
    }
  }
}
