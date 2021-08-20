import 'package:refrigerator/my_main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:date_format/date_format.dart';

class Pair {
  String name;
  int expireDate;
  Pair({required this.name, required this.expireDate});
}

List<Pair> dataSet = [
  Pair(name: "가지", expireDate: 5),
  Pair(name: "감자", expireDate: 30),
  Pair(name: "고추", expireDate: 30),
  Pair(name: "고추장", expireDate: 730),
  Pair(name: "달걀", expireDate: 20),
  Pair(name: "당근", expireDate: 14),
  Pair(name: "대파", expireDate: 10),
  Pair(name: "돼지고기", expireDate: 3),
  Pair(name: "된장", expireDate: 730),
  Pair(name: "두부", expireDate: 14),
  Pair(name: "레몬", expireDate: 7),
  Pair(name: "마늘", expireDate: 14),
  Pair(name: "마요네즈", expireDate: 240),
  Pair(name: "머스타드", expireDate: 365),
  Pair(name: "무", expireDate: 7),
  Pair(name: "바나나", expireDate: 7),
  Pair(name: "바비큐소스", expireDate: 120),
  Pair(name: "배", expireDate: 7),
  Pair(name: "버섯", expireDate: 5),
  Pair(name: "복숭아", expireDate: 5),
  Pair(name: "사과", expireDate: 14),
  Pair(name: "소고기", expireDate: 5),
  Pair(name: "수박", expireDate: 5),
  Pair(name: "슬라이스치즈", expireDate: 90),
  Pair(name: "시금치", expireDate: 3),
  Pair(name: "식빵", expireDate: 3),
  Pair(name: "양배추", expireDate: 7),
  Pair(name: "양파", expireDate: 7),
  Pair(name: "오렌지", expireDate: 7),
  Pair(name: "오이", expireDate: 7),
  Pair(name: "요거트", expireDate: 14),
  Pair(name: "우유", expireDate: 10),
  Pair(name: "주스", expireDate: 30),
  Pair(name: "참외", expireDate: 7),
  Pair(name: "커피", expireDate: 77),
  Pair(name: "케찹", expireDate: 365),
  Pair(name: "콩나물", expireDate: 8),
  Pair(name: "키위", expireDate: 7),
  Pair(name: "토마토", expireDate: 14),
  Pair(name: "파스타소스", expireDate: 300),
  Pair(name: "포도", expireDate: 4),
];

void addData(int index, List<ListData> listDatas) {
  print("add $index");
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  final now = tz.TZDateTime.now(tz.local);
  int lastData = dataSet[index].expireDate;
  int expireYear = now.year + (lastData ~/ 365);
  lastData %= 365;
  int expireMonth = now.month + (lastData ~/ 31);
  lastData %= 30;
  int expireDay = now.day + lastData;

  if (expireDay > 31) {
    expireDay -= 31;
    expireMonth++;
  }
  if (expireMonth > 12) {
    expireMonth -= 12;
    expireYear++;
  }

  listDatas.add(ListData(
      purchaseDate: formatDate(
          DateTime(now.year, now.month, now.day), [yyyy, '-', mm, '-', 'dd']),
      expirationDate: formatDate(DateTime(expireYear, expireMonth, expireDay),
          [yyyy, '-', mm, '-', 'dd']),
      itemName: dataSet[index].name));
}
