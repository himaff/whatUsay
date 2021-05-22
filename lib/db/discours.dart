import 'package:hive/hive.dart';

part 'discours.g.dart';

@HiveType(typeId: 0)
class Discours extends HiveObject {

  @HiveField(0)
  String title;

  @HiveField(1)
  String dialogEn;

  @HiveField(2)
  String dialogFr;

  @HiveField(3)
  String author;

  Discours(this.title, this.dialogEn, this.dialogFr, this.author);

  //String key() => title.hashCode.toString();
}