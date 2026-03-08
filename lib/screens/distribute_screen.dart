import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DistributeScreen extends StatefulWidget {
  const DistributeScreen({super.key});

  @override
  State<DistributeScreen> createState() => _DistributeScreenState();
}

class _DistributeScreenState extends State<DistributeScreen> {

  String? selectedBook;
  final quantityController = TextEditingController();

  Future<void> reportScore() async {

    if (selectedBook == null) return;

    int quantity = int.parse(quantityController.text.trim());

    final docRef = FirebaseFirestore.instance
        .collection("books")
        .doc(selectedBook);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.runTransaction((transaction) async {

      final snapshot = await transaction.get(docRef);

      int currentStock = snapshot["currentStock"];
      int threshold = snapshot["threshold"];
      String bookName = snapshot["name"];

      if (currentStock < quantity) {
        throw Exception("Not enough stock");
      }

      int newStock = currentStock - quantity;

      transaction.update(docRef, {
        "currentStock": newStock
      });

      // Log Report
      FirebaseFirestore.instance
          .collection("distribution_reports")
          .add({
        "devoteeEmail": user?.email,
        "bookCode": selectedBook,
        "bookName": bookName,
        "quantity": quantity,
        "date": Timestamp.now(),
      });

      if (newStock <= threshold) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("⚠ Stock Below Threshold!")),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report Submitted")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Report Scores")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("books").snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final books = snapshot.data!.docs;

                return DropdownButton<String>(
                  value: selectedBook,
                  hint: const Text("Select Book"),
                  isExpanded: true,
                  items: books.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBook = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Quantity Distributed"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: reportScore,
              child: const Text("Submit Report"),
            ),
          ],
        ),
      ),
    );
  }
}