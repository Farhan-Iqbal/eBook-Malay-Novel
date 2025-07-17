import 'package:flutter/material.dart';

class ReadEbookScreen extends StatelessWidget {
  final String ebookId;
  final VoidCallback onFinish;

  const ReadEbookScreen({
    super.key,
    required this.ebookId,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Read Ebook"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "AI-generated essay or PDF viewer goes here for ebookId: $ebookId",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                onFinish();
                Navigator.pop(context);
              },
              child: const Text("Mark as Finished"),
            ),
          )
        ],
      ),
    );
  }
}
