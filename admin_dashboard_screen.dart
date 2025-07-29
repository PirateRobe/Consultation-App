
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_test/routes/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Admin dashboard screen to manage and approve bookings
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();
  String _filter = '';

  /// Returns a stream of bookings based on search filter
  Stream<QuerySnapshot> _bookingsStream() {
    final base = FirebaseFirestore.instance.collection('bookings');
    return _filter.isEmpty
        ? base.orderBy('dateTime').snapshots()
        : base.where('studentId', isEqualTo: _filter).snapshots();
  }

  /// Shows confirmation dialog before deleting a booking
  Future<void> _confirmDelete(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text(
              "Are you sure you want to delete this booking?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking deleted")));
    }
  }

  /// Updates booking status to 'confirmed'
  Future<void> _approveBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'confirmed'});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Booking approved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "View Profile",
            onPressed: () => Navigator.pushNamed(context, RouteManager.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteManager.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by Student ID",
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filter = '');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => setState(() => _filter = value.trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _bookingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No bookings found."));
                }

                final bookings = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data =
                        bookings[index].data()! as Map<String, dynamic>;
                    final docId = bookings[index].id;
                    final date = DateFormat.yMMMd().add_jm().format(
                      data['dateTime'].toDate(),
                    );
                    final status = data['status'] ?? 'pending';

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color:
                          status == 'confirmed'
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${data['lecturer']} - ${data['topic']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Student ID: ${data['studentId']}"),
                            Text("Date: $date"),
                            Text(
                              "Status: $status",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    status == 'confirmed'
                                        ? Colors.green
                                        : Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (status == 'pending')
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text("Approve"),
                                    onPressed: () => _approveBooking(docId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Delete"),
                                  onPressed: () => _confirmDelete(docId),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
