import 'dart:async';
import 'package:student_hub/features/grades/domain/entities/grade_item.dart';

abstract class GradeRepository {
  Future<List<GradeItem>> getGrades();
  Stream<List<GradeItem>> watchGrades();
  Future<List<GradeItem>> getGradesBySubject(String subjectId);
  Future<GradeItem?> getGradeById(String id);
  Future<List<SubjectGrades>> getSubjectGrades();
  Future<double> getOverallAverage();
}
