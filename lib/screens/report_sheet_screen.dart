import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportSheetScreen extends StatelessWidget {
  const ReportSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Distribution Report Sheet")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("distribution_reports")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {

              final report = reports[index];

              DateTime date =
              (report["date"] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(report["bookName"]),
                  subtitle: Text(
                      "Devotee: ${report["devoteeEmail"]}\n"
                          "Quantity: ${report["quantity"]}\n"
                          "Date: ${DateFormat('dd MMM yyyy – hh:mm a').format(date)}"
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}