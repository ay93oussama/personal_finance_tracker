import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transactions/transactions_cubit.dart';
import '../../core/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/transactions/transaction_categories.dart';

class AddEditTransactionPage extends StatefulWidget {
  const AddEditTransactionPage({super.key, this.initial});

  final TransactionModel? initial;

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();

  late TransactionType _type;
  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? TransactionType.expense;
    final categories = TransactionCategories.forType(_type);
    final initialCategory = initial?.category;
    _category = initialCategory != null && categories.contains(initialCategory)
        ? initialCategory
        : TransactionCategories.defaultFor(_type);
    _date = initial?.date ?? DateTime.now();
    _categoryController.text = _category;
    if (initial != null) {
      _amountController.text = initial.amount.toStringAsFixed(2);
      _noteController.text = initial.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      amount: amount,
      title: _category,
      category: _category,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    final cubit = context.read<TransactionsCubit>();
    await (widget.initial == null
        ? cubit.addTransaction(transaction)
        : cubit.updateTransaction(transaction));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openCategoryPicker() async {
    final categories = TransactionCategories.forType(_type);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.85;
        String query = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = categories
                .where(
                  (category) =>
                      category.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

            return SizedBox(
              height: height,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select a category',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search categories',
                      ),
                      onChanged: (value) => setState(() => query = value.trim()),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Text(
                        'No matches found.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final category = filtered[index];
                            return ListTile(
                              title: Text(category),
                              trailing: category == _category
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () => Navigator.of(context).pop(category),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _category = selected;
        _categoryController.text = selected;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final initial = widget.initial;
    if (initial == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await context.read<TransactionsCubit>().deleteTransaction(initial.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  final nextType = selection.first;
                  final categories = TransactionCategories.forType(nextType);
                  final nextCategory = categories.contains(_category)
                      ? _category
                      : TransactionCategories.defaultFor(nextType);
                  setState(() {
                    _type = nextType;
                    _category = nextCategory;
                    _categoryController.text = nextCategory;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.expand_more),
                ),
                onTap: _openCategoryPicker,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '€ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required.';
                  }
                  final amount =
                      double.tryParse(value.trim().replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(AppFormatters.shortDate(_date)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
