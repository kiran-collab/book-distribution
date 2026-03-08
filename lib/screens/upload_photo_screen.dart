import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool isUploading = false;
  DateTime selectedDate = DateTime.now();

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> uploadPhotos() async {

    if (_selectedImages.isEmpty) return;

    setState(() => isUploading = true);

    try {

      final user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      final currentUserName = userDoc.data()?["name"] ?? "Unknown";

      for (var image in _selectedImages) {

        final fileName =
            DateTime.now().millisecondsSinceEpoch.toString();

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("distribution_photos/$fileName.jpg");

        await storageRef.putFile(File(image.path));

        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("distribution_photos")
            .add({
          "imageUrl": downloadUrl,
          "uploadedBy": currentUserName,
          "userId": user.uid,
          "date": Timestamp.fromDate(selectedDate),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Images Uploaded Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedImages.clear();
      });

    } catch (e) {
      print("UPLOAD ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Photos")),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "Selected Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickDate,
                child: const Text("Select Date"),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: pickImages,
                child: const Text("Select Photos"),
              ),

              const SizedBox(height: 10),

              if (_selectedImages.isNotEmpty)
                Text("${_selectedImages.length} images selected"),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: isUploading ? null : uploadPhotos,
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}