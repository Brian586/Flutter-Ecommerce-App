
class Time {
  static String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0) {
      //time = format.format(date);
      time = 'now';
    }else if(diff.inSeconds > 0 && diff.inMinutes == 0) {
      time = diff.inSeconds.toString() + ' s';
    } else if(diff.inMinutes > 0 && diff.inHours == 0) {
      time = diff.inMinutes.toString() + ' min';
    } else if(diff.inHours > 0 && diff.inDays == 0) {
      time = diff.inHours.toString() + ' h';
    }
    else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays < 2) {
        time = diff.inDays.toString() + ' day ago';
      } else {
        time = diff.inDays.toString() + ' days ago';
      }
    } else {
      if (diff.inDays < 14) {
        time = (diff.inDays / 7).floor().toString() + ' week ago';
      } else {

        time = (diff.inDays / 7).floor().toString() + ' weeks ago';
      }
    }

    return time;
  }
}