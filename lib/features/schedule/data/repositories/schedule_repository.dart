import 'package:student_hub/features/schedule/domain/entities/schedule_item.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleItem>> getSchedule();
  Stream<List<ScheduleItem>> watchSchedule();
  Future<void> addLesson(ScheduleItem lesson);
  Future<void> updateLesson(ScheduleItem lesson);
  Future<void> deleteLesson(String lessonId);
}
