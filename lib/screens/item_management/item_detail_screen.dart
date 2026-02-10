// external
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/screens/item_management/widgets/item_image_widgets.dart';
import 'package:expiryclock/screens/item_management/widgets/item_form_fields.dart';
import 'package:expiryclock/screens/item_management/services/item_detail_service.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, this.item});
  final ExpiryItem? item;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late final TextEditingController _name;
  late final TextEditingController _category;
  late DateTime _expiry;
  late final TextEditingController _memo;
  late final TextEditingController _quantity;
  int _notifyBefore = 2;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _category = TextEditingController(text: item?.category ?? '');
    _expiry = item?.expiryDate ?? DateTime.now().add(const Duration(days: 7));
    _memo = TextEditingController(text: item?.memo ?? '');
    _quantity = TextEditingController(text: (item?.quantity ?? 1).toString());
    _notifyBefore = item?.notifyBeforeDays ?? 2;
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _memo.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _showFullScreenImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageView(imagePath: widget.item!.images.first),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  void _decrementQuantity() {
    final current = int.tryParse(_quantity.text) ?? 1;
    if (current > 0) {
      setState(() => _quantity.text = (current - 1).toString());
    }
  }

  void _incrementQuantity() {
    final current = int.tryParse(_quantity.text) ?? 1;
    setState(() => _quantity.text = (current + 1).toString());
  }

  Future<void> _save() async {
    final repository = ref.read(itemRepositoryProvider);
    final service = ItemDetailService(repository);

    await service.saveItem(
      existingItem: widget.item,
      name: _name.text,
      category: _category.text,
      expiryDate: _expiry,
      notifyBeforeDays: _notifyBefore,
      memo: _memo.text,
      quantity: int.tryParse(_quantity.text) ?? 1,
    );

    if (!mounted) return;
    ItemDetailService.navigateToList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 상세/수정')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ItemImagePreview(item: widget.item, onTap: _showFullScreenImage),
            const SizedBox(height: 16),
            ItemNameField(controller: _name),
            const SizedBox(height: 12),
            ItemCategoryField(controller: _category),
            const SizedBox(height: 12),
            ItemExpiryDateField(expiryDate: _expiry, onPickDate: _pickDate),
            const SizedBox(height: 12),
            ItemNotificationAndQuantityField(
              notifyBefore: _notifyBefore,
              onNotifyBeforeChanged: (v) =>
                  setState(() => _notifyBefore = v ?? _notifyBefore),
              quantityController: _quantity,
              onDecrementQuantity: _decrementQuantity,
              onIncrementQuantity: _incrementQuantity,
            ),
            const SizedBox(height: 12),
            ItemMemoField(controller: _memo),
            const SizedBox(height: 24),
            ItemSaveButton(onSave: _save),
          ],
        ),
      ),
    );
  }
}
