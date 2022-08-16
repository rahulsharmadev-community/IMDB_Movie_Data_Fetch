class GeneralFunciton {
  String mmtoH(int min) {
    print(min);
    int hour;
    if (min > 60) {
      hour = (min / 60).toInt();
      return "${hour}h ${min - (hour * 60)}min";
    } else
      return "${min}min";
  }
}
