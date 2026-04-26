import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({super.key, this.message = 'Загрузка...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
