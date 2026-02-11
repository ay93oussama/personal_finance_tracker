import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/helpers/app_formatters.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/core/services/id_service.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/domain/usecases/transactions/transaction_categories.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_cubit.dart';

class AddEditTransactionPage extends StatefulWidget {
  const AddEditTransactionPage({super.key, this.initial});

  final Transaction? initial;

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
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.enterValidAmount)));
      return;
    }

    final transaction = Transaction(
      id: widget.initial?.id ?? IdService.nextId(),
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
                      context.l10n.selectCategory,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: context.l10n.searchCategories,
                      ),
                      onChanged: (value) =>
                          setState(() => query = value.trim()),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Text(
                        context.l10n.noMatchesFound,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
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
          title: Text(context.l10n.deleteTransactionTitle),
          content: Text(context.l10n.deleteTransactionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<TransactionsCubit>().deleteTransaction(initial.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.editTransactionTitle
              : context.l10n.addTransactionTitle,
        ),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: context.l10n.delete,
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(onPressed: _save, child: Text(context.l10n.save)),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(context.l10n.expense),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(context.l10n.income),
                    icon: const Icon(Icons.add_circle_outline),
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
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.expand_more),
                ),
                onTap: _openCategoryPicker,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.categoryRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.amount,
                  prefixText: '€ ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.amountRequired;
                  }
                  final amount = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );
                  if (amount == null || amount <= 0) {
                    return context.l10n.enterValidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.date),
                subtitle: Text(AppFormatters.shortDate(_date)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.l10n.notesOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
