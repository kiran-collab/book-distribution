import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {

  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  final thresholdController = TextEditingController();

  bool isLoading = false;

  Future<void> addBook() async {
    final code = codeController.text.trim();
    final name = nameController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final stock = int.tryParse(stockController.text.trim()) ?? 0;
    final threshold = int.tryParse(thresholdController.text.trim()) ?? 0;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("books")
          .doc(code)
          .set({
        "name": name,
        "currentStock": stock,
        "threshold": threshold,
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Book added successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    stockController.dispose();
    thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Initialize / Add Book"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: "Book Code (e.g. SB)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Book Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: "Current Stock",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 15),

              TextField(
                controller: thresholdController,
                decoration: const InputDecoration(
                  labelText: "Threshold",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addBook,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Add Book"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}