import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

void exportAndShareStudents(List<dynamic> studentList) async {
  List<List<dynamic>> rows = [];
  rows.add(["name", "student number", "department", "level", "GPA"]);

  for (var student in studentList) {
    rows.add([
      student.name ?? '',
      student.studentNumber ?? '',
      student.department ?? '',
      student.level ?? 0,
      student.gpa ?? 0.0,
    ]);
  }

  String csvData = const ListToCsvConverter().convert(rows);

  final XFile file = XFile.fromData(
    Uint8List.fromList(csvData.codeUnits),
    name: 'students_export.csv',
    mimeType: 'text/csv',
  );

  await Share.shareXFiles([file], text: 'Exported Student List');
}
