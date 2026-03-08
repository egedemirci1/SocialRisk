import '../../../shared/models/enums.dart';

class VoteModel {
  final String voterId;
  final VoteValue value;
  final bool timedOut;
  final bool penaltyApplied;

  const VoteModel({
    required this.voterId,
    required this.value,
    this.timedOut = false,
    this.penaltyApplied = false,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json, String docId) {
    return VoteModel(
      voterId: docId,
      value: VoteValue.values.firstWhere(
        (e) => e.name == json['value'],
        orElse: () => VoteValue.neutral,
      ),
      timedOut: json['timedOut'] as bool? ?? false,
      penaltyApplied: json['penaltyApplied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.name,
      'timedOut': timedOut,
      'penaltyApplied': penaltyApplied,
    };
  }
}

