// GENERATED CODE - DO NOT MODIFY BY HAND
// This file should be generated using: flutter pub run build_runner build
// For now, this is a placeholder. Run the build_runner to generate the actual code.

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 1;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      chatId: fields[1] as String,
      content: fields[2] as String,
      roleString: fields[3] as String,
      timestamp: fields[4] as DateTime,
      isStreaming: fields[5] as bool,
      isError: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.roleString)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isStreaming)
      ..writeByte(6)
      ..write(obj.isError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
