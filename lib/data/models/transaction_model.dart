import 'package:hive/hive.dart';

import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.title,
    required super.category,
    required super.date,
    super.note,
  });

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      title: transaction.title,
      category: transaction.category,
      date: transaction.date,
      note: transaction.note,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      type: type,
      amount: amount,
      title: title,
      category: category,
      date: date,
      note: note,
    );
  }
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
    final title = reader.availableBytes > 0 ? reader.readString() : category;
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
