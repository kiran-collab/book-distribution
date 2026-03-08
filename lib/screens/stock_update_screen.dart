import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockUpdateScreen extends StatefulWidget {
  const StockUpdateScreen({super.key});

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {

  String? selectedBook;
  final quantityController = TextEditingController();

  Future<void> updateStock() async {
    if (selectedBook == null) return;

    int quantity = int.parse(quantityController.text.trim());

    final docRef =
        FirebaseFirestore.instance.collection("books").doc(selectedBook);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int currentStock = snapshot["currentStock"];

      transaction.update(docRef, {
        "currentStock": currentStock + quantity
      });
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Update")),
      body: const Center(child: Text("Stock Update Screen")),
    );
  }
}