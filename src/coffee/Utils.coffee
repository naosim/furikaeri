Utils = {}
String::replaceAll = (before, after) -> this.split(before).join(after)
Utils.putZero = (num) -> if parseInt(num, 10) < 10 then '0' + num else num
