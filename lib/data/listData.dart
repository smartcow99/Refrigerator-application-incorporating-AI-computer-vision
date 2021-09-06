import 'dart:convert';

class ListData {
  String purchaseDate;
  String expirationDate;
  String itemName;

  ListData(
      {required this.purchaseDate,
      required this.expirationDate,
      required this.itemName});

  factory ListData.fromJson(Map<String, dynamic> parsedJson) {
    return ListData(
        purchaseDate: parsedJson['purchaseDate'],
        expirationDate: parsedJson['expirationDate'],
        itemName: parsedJson['itemName']);
  }
  toJson() => {
        'purchaseDate': this.purchaseDate,
        'expirationDate': this.expirationDate,
        'itemName': this.itemName
      };

  String toString() => purchaseDate + "/" + expirationDate + "/" + itemName;
  String calLastDate(ListData data) {
    String ret;
    DateTime today = DateTime.now();
    today.difference(DateTime.parse(data.expirationDate)).inDays.toInt() > 0
        ? ret =
            "D+${DateTime.parse(data.expirationDate).difference(today).inDays.toInt() * -1}"
        : ret =
            "D-${DateTime.parse(data.expirationDate).difference(today).inDays.toInt()}";
    return ret;
  }
}

String listDatasToJson(List<ListData> listDatas) =>
    jsonEncode(listDatas.map((i) => i.toJson()).toList()).toString();

List<ListData> listDatasFromJson(String json) {
  List<dynamic> parsedJson = jsonDecode(json);
  print("parsedJson = $parsedJson");
  List<ListData> listdatas = [];
  for (int i = 0; i < parsedJson.length; i++) {
    listdatas.add(ListData.fromJson(parsedJson[i]));
  }
  return listdatas;
}
