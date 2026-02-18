import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/screens/item_screens/services/item_list_service.dart';
import 'package:expiryclock/screens/item_screens/constants/sort_option.dart';

class ItemListScreen extends ConsumerStatefulWidget {
  const ItemListScreen({super.key});

  @override
  ConsumerState<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends ConsumerState<ItemListScreen> {
  late final ItemListService _service;
  late final ValueNotifier<int> _versionNotifier;
  SortOption _currentSortOption = SortOption.expiryDateAsc;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(itemRepositoryProvider);
    _service = ItemListService(repository);
    _versionNotifier = _service.versionNotifier;
    _versionNotifier.addListener(_refresh);
  }

  @override
  void dispose() {
    _versionNotifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _pickImageFromGallery() async {
    try {
      final imagePath = await _service.pickImageFromGallery();

      if (imagePath != null && mounted) {
        ItemListService.navigateToRegister(context, imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지를 불러오는데 실패했습니다: $e')));
      }
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
              final isSelected = _currentSortOption == option;
              return ListTile(
                title: Text(option.displayName),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _currentSortOption = option;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _service.getAllItems(sortOption: _currentSortOption);
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 리스트'),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
          ),
          IconButton(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: '갤러리',
          ),
          IconButton(
            onPressed: () => ItemListService.navigateToCamera(context),
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: '카메라',
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('아직 등록된 아이템이 없어요.'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _ItemTile(item: items[i]),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'settings_button',
        onPressed: () => ItemListService.navigateToSettings(context),
        tooltip: '설정',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.settings),
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item});
  final ExpiryItem item;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이템 삭제'),
        content: Text('\'${item.name}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repository = ref.read(itemRepositoryProvider);
      final service = ItemListService(repository);
      await service.deleteItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\'${item.name}\'이(가) 삭제되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = item.dDay;
    final dText = d == 0 ? 'D-Day' : (d > 0 ? 'D-$d' : 'D+${-d}');
    return ListTile(
      title: Text(item.name),
      subtitle: Text('${formatDate(item.expiryDate)}  ($dText)'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: '삭제',
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => ItemListService.navigateToDetail(context, item),
    );
  }
}
