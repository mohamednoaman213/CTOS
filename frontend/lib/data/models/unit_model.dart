import 'package:equatable/equatable.dart';

enum UnitStatus { available, occupied }

class UnitModel extends Equatable {
  final String id;
  final String name;
  final UnitStatus status;

  const UnitModel({
    required this.id,
    required this.name,
    required this.status,
  });

  static final mockList = [
    const UnitModel(id: '14', name: 'UNIT 14', status: UnitStatus.available),
    const UnitModel(id: '23', name: 'UNIT 23', status: UnitStatus.occupied),
    const UnitModel(id: '58', name: 'UNIT 58', status: UnitStatus.occupied),
    const UnitModel(id: '12', name: 'UNIT 12', status: UnitStatus.available),
    const UnitModel(id: '19', name: 'UNIT 19', status: UnitStatus.available),
    const UnitModel(id: '27', name: 'UNIT 27', status: UnitStatus.available),
  ];

  @override
  List<Object?> get props => [id];
}
