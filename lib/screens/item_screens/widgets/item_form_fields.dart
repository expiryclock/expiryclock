// external
import 'package:flutter/material.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';

/// 아이템 이름 입력 필드
class ItemNameField extends StatelessWidget {
  const ItemNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: '아이템 이름'),
    );
  }
}

/// 카테고리 입력 필드
class ItemCategoryField extends StatelessWidget {
  const ItemCategoryField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: '카테고리'),
    );
  }
}

/// 만료 기한 선택 필드
class ItemExpiryDateField extends StatelessWidget {
  const ItemExpiryDateField({
    super.key,
    required this.expiryDate,
    required this.onPickDate,
  });

  final DateTime expiryDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('만료기한: ${formatDate(expiryDate)}')),
        TextButton(onPressed: onPickDate, child: const Text('변경')),
      ],
    );
  }
}

/// 알림 및 수량 설정 필드
class ItemNotificationAndQuantityField extends StatelessWidget {
  const ItemNotificationAndQuantityField({
    super.key,
    required this.notifyBefore,
    required this.onNotifyBeforeChanged,
    required this.quantityController,
    required this.onDecrementQuantity,
    required this.onIncrementQuantity,
  });

  final int notifyBefore;
  final ValueChanged<int?> onNotifyBeforeChanged;
  final TextEditingController quantityController;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onIncrementQuantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text('푸시 알림: '),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: notifyBefore,
                items: const [0, 1, 2, 3, 5, 7]
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text('$d일 전')),
                    )
                    .toList(),
                onChanged: onNotifyBeforeChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: onDecrementQuantity,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 28,
              ),
              Expanded(
                child: TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: '수량'),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    // 0 미만 입력 방지
                    final num = int.tryParse(value);
                    if (num != null && num < 0) {
                      quantityController.text = '0';
                      quantityController.selection = TextSelection.fromPosition(
                        TextPosition(offset: quantityController.text.length),
                      );
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: onIncrementQuantity,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 28,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 메모 입력 필드
class ItemMemoField extends StatelessWidget {
  const ItemMemoField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: '메모'),
      maxLines: 3,
    );
  }
}

/// 저장 버튼
class ItemSaveButton extends StatelessWidget {
  const ItemSaveButton({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSave,
        icon: const Icon(Icons.save_outlined),
        label: const Text('저장'),
      ),
    );
  }
}
