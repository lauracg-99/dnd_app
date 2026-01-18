import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/class_viewmodel.dart';
import '../../../models/class_model.dart';
import 'package:dnd_app/views/information/class_detail_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({Key? key}) : super(key: key);

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSource = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Schedule the loading to happen after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
    });
  }

  Future<void> _loadClasses() async {
    if (!mounted) return; // Safety check
    setState(() => _isLoading = true);
    final viewModel = context.read<ClassesViewModel>();
    await viewModel.loadClasses();
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Classes'),
        actions: [
          /*           IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ), */
        ],
      ),
      body: Consumer<ClassesViewModel>(
        builder: (context, viewModel, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadClasses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final classes = viewModel.classes;
          if (classes.isEmpty) {
            return const Center(child: Text('No classes found'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search classes...',
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
                                viewModel.setSearchQuery('');
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    viewModel.setSearchQuery(value);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final dndClass = classes[index];
                    return _buildClassCard(dndClass);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassCard(DndClass dndClass) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          dndClass.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Hit Die: ${dndClass.hitDie.toUpperCase()}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailScreen(className: dndClass.name),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final viewModel = context.read<ClassesViewModel>();
        final sources = viewModel.getAllAvailableSources().toList()..sort();

        return AlertDialog(
          title: const Text('Filter Classes'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Source Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...sources.map(
                  (source) => RadioListTile<String>(
                    title: Text(source.toUpperCase()),
                    value: source,
                    groupValue: _selectedSource,
                    onChanged: (value) {
                      setState(() {
                        _selectedSource = value!;
                      });
                      viewModel.setSelectedSource(value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                if (sources.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSource = '';
                      });
                      viewModel.setSelectedSource('');
                      Navigator.pop(context);
                    },
                    child: const Text('Clear Filter'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
