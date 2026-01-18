import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/feat_model.dart';
import '../../viewmodels/feats_viewmodel.dart';

class FeatsScreen extends StatefulWidget {
  const FeatsScreen({super.key});

  @override
  State<FeatsScreen> createState() => _FeatsScreenState();
}

class _FeatsScreenState extends State<FeatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeatsViewModel>().loadFeats();
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
        title: const Text('Feats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search feats...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
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
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<FeatsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Text(
                'Error: ${viewModel.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final feats =
              _searchQuery.isEmpty
                  ? viewModel.feats
                  : viewModel.feats
                      .where(
                        (feat) => feat.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();

          if (feats.isEmpty) {
            return const Center(child: Text('No feats found.'));
          }

          return ListView.builder(
            itemCount: feats.length,
            itemBuilder: (context, index) {
              final feat = feats[index];
              return _buildFeatCard(context, feat);
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatCard(BuildContext context, Feat feat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          feat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          feat.description.split('\n').first,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showFeatDetails(context, feat);
        },
      ),
    );
  }

  void _showFeatDetails(BuildContext context, Feat feat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            initialChildSize: 0.5,
            minChildSize: 0.25,
            builder:
                (_, controller) => SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        feat.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Source: ${feat.source}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feat.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
