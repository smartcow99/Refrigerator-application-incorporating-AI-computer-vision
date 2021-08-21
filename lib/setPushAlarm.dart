import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'my_info.dart';
import 'my_main.dart';

Future pushNotif(List<ListData> listDatas, int check) async {
  final notiTitle = '냉장고';
  final notiDesc = '냉장고에 곧 썩는 음식이 있어요!';

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final result = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  var android = AndroidNotificationDetails('id', notiTitle, notiDesc,
      importance: Importance.max, priority: Priority.max);
  var ios = IOSNotificationDetails();
  var detail = NotificationDetails(android: android, iOS: ios);

  if (result!) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup('id');
  }
  if (check != -1) {
    for (int i = 0; i < listDatas.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        notiTitle,
        notiDesc,
        _setNotiTime(i, listDatas),
        detail,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}

tz.TZDateTime _setNotiTime(int index, List<ListData> listDatas) {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  var tmp = listDatas[index].expirationDate.split('-');
  var alarmDate = [
    int.parse(tmp[0]),
    int.parse(tmp[1]),
    int.parse(tmp[2]),
  ];
  if (alarmDate[2] - alarmCycle < 0) {
    alarmDate[1]--;
    if (alarmDate[1] <= 7 && alarmDate[1] % 2 == 1 ||
        alarmDate[1] > 7 && alarmDate[1] % 2 == 0)
      alarmDate[2] = 31 + alarmDate[2] - alarmCycle;
    else
      alarmDate[2] = 30 + alarmDate[2] - alarmCycle;
  } else {
    alarmDate[2] -= alarmCycle;
  }
  return tz.TZDateTime(
      tz.local, alarmDate[0], alarmDate[1], alarmDate[2], 10, 00);
}
