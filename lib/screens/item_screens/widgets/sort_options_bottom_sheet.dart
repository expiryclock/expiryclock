import 'package:flutter/material.dart';
import 'package:expiryclock/screens/item_screens/constants/sort_option.dart';

class SortOptionsBottomSheet extends StatelessWidget {
  const SortOptionsBottomSheet({
    super.key,
    required this.currentSortOption,
    required this.onSortOptionSelected,
  });

  final SortOption currentSortOption;
  final ValueChanged<SortOption> onSortOptionSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '정렬 기준',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...SortOption.values.map((option) {
            final isSelected = currentSortOption == option;
            return ListTile(
              title: Text(option.displayName),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              selected: isSelected,
              onTap: () {
                Navigator.pop(context);
                onSortOptionSelected(option);
              },
            );
          }),
        ],
      ),
    );
  }
}
