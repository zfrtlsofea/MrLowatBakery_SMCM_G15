import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.orange,
      ),
      body: user == null
          ? const Center(
              child: Text('Please log in to view your orders.'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('cart')
                  .where('isPaid', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No orders available.'),
                  );
                }

                final items = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index].data() as Map<String, dynamic>;
                    final itemName = item['name'] ?? 'Unknown Item';
                    final bookingDate = item['bookingDate'] ?? 'Unknown Date';
                    final currentStatus = item['status'] ?? 'Accepted';
                    final isCompleted = currentStatus == 'Completed';
                    final isCancelled = item['isCancelled'] ?? false;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCancelled ? Colors.red : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          isCancelled
                              ? 'This order has been cancelled.'
                              : 'Booking Date: $bookingDate',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _showOrderDetails(context, item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCancelled
                                ? Colors.grey
                                : (isCompleted ? Colors.green : Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isCancelled ? 'Cancelled' : 'View Details',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final itemName = order['name'] ?? 'Unknown Item';
    final bookingDate = order['bookingDate'] ?? 'Unknown Date';
    final currentStatus = order['status'] ?? 'Accepted';
    final isCancelled = order['isCancelled'] ?? false;

// SCM-MINOR: Extend tracking stages to include "Pending Payment" and "Out for Delivery" (UI timeline enhancement)
// Note: trivial comment change only for SCM simulation (feature not fully implemented)
    final processStages = ["Accepted", "Processing", "Ready", "Completed"];

    final processStages = ["Accepted", "Processing", "Ready", "Completed"];
    final steps = processStages.map((stage) {
      return OrderStepData(
        title: stage,
        isCompleted: processStages.indexOf(currentStatus) >=
            processStages.indexOf(stage),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            isCancelled ? 'Order Cancelled' : 'Order Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isCancelled ? Colors.red : Colors.black,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Item: $itemName',
                style: const TextStyle(fontSize: 16),
              ),
              if (!isCancelled)
                Text(
                  'Booking Date: $bookingDate',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              if (!isCancelled)
                const Text(
                  'Order Progress:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              if (!isCancelled) const SizedBox(height: 10),
              if (!isCancelled)
                Column(
                  children: List.generate(steps.length, (index) {
                    final step = steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            step.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color:
                                step.isCompleted ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  step.isCompleted ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              if (isCancelled)
                const Text(
                  "This order has been cancelled and a refund has been issued. If you have any questions, please don't hesitate to contact support.",
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class OrderStepData {
  final String title;
  final bool isCompleted;

  OrderStepData({required this.title, required this.isCompleted});
}
