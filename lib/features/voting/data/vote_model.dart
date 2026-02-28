import '../../../shared/models/enums.dart';

class VoteModel {
  final String voterId;
  final VoteValue value;

  const VoteModel({
    required this.voterId,
    required this.value,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json, String docId) {
    return VoteModel(
      voterId: docId,
      value: VoteValue.values.firstWhere(
        (e) => e.name == json['value'],
        orElse: () => VoteValue.neutral,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.name,
    };
  }
}
