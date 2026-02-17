import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/helpers/app_formatters.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/core/services/id_service.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/presentation/states/cubits/transaction_form/transaction_form_cubit.dart';
import 'package:tracker/presentation/states/cubits/transaction_form/transaction_form_state.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_cubit.dart';
import 'package:tracker/presentation/widgets/balance_card.dart';
import 'package:tracker/presentation/widgets/common/app_slivers.dart';
import 'package:tracker/presentation/widgets/section_header.dart';

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
  late final TransactionFormCubit _formCubit;
  StreamSubscription<String>? _categorySyncSubscription;

  @override
  void initState() {
    super.initState();
    _formCubit = TransactionFormCubit(
      idGenerator: IdService.nextId,
      initial: widget.initial,
    );

    final initial = widget.initial;
    _categoryController.text = _formCubit.state.category;

    if (initial != null) {
      _amountController.text = initial.amount.toStringAsFixed(2);
      _noteController.text = initial.note ?? '';
    }

    _categorySyncSubscription = _formCubit.stream
        .map((state) => state.category)
        .distinct()
        .listen((category) {
          if (_categoryController.text == category) {
            return;
          }
          _categoryController.text = category;
        });

    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _categorySyncSubscription?.cancel();
    _amountController.removeListener(_onAmountChanged);
    _formCubit.close();
    _amountController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickDate(TransactionFormState formState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.date,
      firstDate: DateTime(2015),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      _formCubit.setDate(picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final transaction = _formCubit.buildTransaction(
      amountInput: _amountController.text,
      noteInput: _noteController.text,
    );

    if (transaction == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.enterValidAmount)));
      return;
    }

    final transactionsCubit = context.read<TransactionsCubit>();
    await (_formCubit.state.isEditing
        ? transactionsCubit.updateTransaction(transaction)
        : transactionsCubit.addTransaction(transaction));

    if (mounted) Navigator.of(context).pop();
  }


  Widget _surfaceCard({required BuildContext context, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: child,
    );
  }

  Widget _detailsCard(BuildContext context, TransactionFormState formState) {
    return _surfaceCard(
      context: context,
      child: Column(
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
            selected: {formState.type},
            onSelectionChanged: (selection) =>
                _formCubit.setType(selection.first),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(

              labelText: context.l10n.amount,
              prefixText: '€ ',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.amountRequired;
              }
              final amount = _formCubit.parseAmount(value);
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
            subtitle: Text(AppFormatters.shortDate(formState.date)),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate(formState),
          ),
        ],
      ),
    );
  }

  Widget _notesCard(BuildContext context) {
    return _surfaceCard(
      context: context,
      child: TextFormField(
        controller: _noteController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: context.l10n.notesOptional,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _openCategoryPicker() async {
    _formCubit.clearCategoryQuery();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: _formCubit,
          child: const _CategoryPickerSheet(),
        );
      },
    );

    if (selected != null) {
      _formCubit.setCategory(selected);
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
    return BlocProvider.value(
      value: _formCubit,
      child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
        builder: (context, formState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                formState.isEditing
                    ? context.l10n.editTransactionTitle
                    : context.l10n.addTransactionTitle,
              ),
              actions: [
                if (formState.isEditing)
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
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    const AppSliverGap(12),
                    AppSliverBox(
                      child: SectionHeader(title: context.l10n.transactions),
                    ),
                    const AppSliverGap(8),
                    AppSliverBox(child: _detailsCard(context, formState)),
                    const AppSliverGap(20),
                    AppSliverBox(
                      child: SectionHeader(title: context.l10n.notesOptional),
                    ),
                    const AppSliverGap(8),
                    AppSliverBox(child: _notesCard(context)),
                    const AppSliverGap(24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
      builder: (context, state) {
        final cubit = context.read<TransactionFormCubit>();
        final height = MediaQuery.of(context).size.height * 0.85;
        final filtered = state.filteredCategories;

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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.l10n.searchCategories,
                  ),
                  onChanged: cubit.setCategoryQuery,
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
                          trailing: category == state.category
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
  }
}
