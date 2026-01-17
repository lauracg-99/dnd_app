import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../viewmodels/items_viewmodel.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // Load items when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsViewModel>().loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('D&D Items'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 8),
                // Type filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedType == null,
                        onSelected: (_) => setState(() => _selectedType = null),
                      ),
                      const SizedBox(width: 4),
                      ...['potion', 'scroll', 'weapon'].map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: FilterChip(
                            label: Text(type.capitalize()),
                            selected: _selectedType == type,
                            onSelected: (_) => setState(() => _selectedType = type),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<ItemsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Apply search and filter
          List<Item> filteredItems = viewModel.items;
          
          if (_searchQuery.isNotEmpty) {
            filteredItems = viewModel.search(_searchQuery);
          }
          
          if (_selectedType != null) {
            filteredItems = filteredItems.where(
              (item) => item.additionalData?['type'] == _selectedType
            ).toList();
          }

          if (filteredItems.isEmpty) {
            return const Center(
              child: Text('No items found. Try adjusting your search or filters.'),
            );
          }

          return ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: item.additionalData?['rarity'] != null
                      ? Chip(
                          label: Text(
                            item.additionalData!['rarity'] as String,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getRarityColor(
                              item.additionalData!['rarity'] as String),
                        )
                      : null,
                  onTap: () {
                    // Navigate to item detail screen or show dialog
                    _showItemDetails(context, item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showItemDetails(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.description),
              const SizedBox(height: 16),
              if (item.additionalData != null) ...{
                const Divider(),
                const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...item.additionalData!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key.capitalize()}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(entry.value.toString())),
                      ],
                    ),
                  );
                }).toList(),
              },
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey[300]!;
      case 'uncommon':
        return Colors.green[100]!;
      case 'rare':
        return Colors.blue[100]!;
      case 'very rare':
        return Colors.purple[100]!;
      case 'legendary':
        return Colors.orange[100]!;
      case 'artifact':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
