import 'package:flutter/material.dart';

/// Filter chip widget for product filtering
class FilterChipsWidget extends StatelessWidget {
  final List<FilterChipData> filters;
  final Function(String) onFilterSelected;

  const FilterChipsWidget({
    Key? key,
    required this.filters,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: filter.isSelected,
              onSelected: (selected) {
                onFilterSelected(filter.value);
              },
              avatar: filter.isSelected
                  ? null
                  : (filter.icon != null ? Icon(filter.icon, size: 18) : null),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: filter.isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: filter.isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data class for filter chip
class FilterChipData {
  final String label;
  final String value;
  final bool isSelected;
  final IconData? icon;

  FilterChipData({
    required this.label,
    required this.value,
    this.isSelected = false,
    this.icon,
  });

  FilterChipData copyWith({
    String? label,
    String? value,
    bool? isSelected,
    IconData? icon,
  }) {
    return FilterChipData(
      label: label ?? this.label,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      icon: icon ?? this.icon,
    );
  }
}
