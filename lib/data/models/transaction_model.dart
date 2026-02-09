import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

enum TransactionType { income, expense }

enum TransactionFilter { all, income, expense }

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.category,
    required this.date,
    this.note,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String title;
  final String category;
  final DateTime date;
  final String? note;

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? title,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, type, amount, title, category, date, note];
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
    }
  }
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 1;

  @override
  TransactionModel read(BinaryReader reader) {
    final id = reader.readString();
    final type = TransactionType.values[reader.readByte()];
    final amount = reader.readDouble();
    final category = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasNote = reader.readBool();
    final note = hasNote ? reader.readString() : null;
    final title =
        reader.availableBytes > 0 ? reader.readString() : category;
    return TransactionModel(
      id: id,
      type: type,
      amount: amount,
      title: title,
      category: category,
      date: date,
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeString(obj.id)
      ..writeByte(obj.type.index)
      ..writeDouble(obj.amount)
      ..writeString(obj.category)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeBool(obj.note != null);
    if (obj.note != null) {
      writer.writeString(obj.note!);
    }
    writer.writeString(obj.title);
  }
}
