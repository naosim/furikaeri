HeaderBar = {}
# 画面右上の時間表示部分
HeaderBar.updateTimeDisplay = ->
  next = ( ->
    result = new Date()
    result.setSeconds(0)
    result.setMilliseconds(0)
    min = result.getMinutes()
    if min < 25
      result.setMinutes(25)
    else if(min < 55)
      result.setMinutes(55)
    else
      result.setHours(result.getHours() + 1)
      result.setMinutes(25)
    return result
  )()
  now = new Date()
  rest = next.getTime() - now.getTime()
  sec = Math.floor(rest / 1000)
  text = "#{Utils.putZero(now.getHours())}:#{Utils.putZero(now.getMinutes())}<br>" + 'ふりかえりまで<br>あと ' + (if sec < 60 then sec + '秒' else Math.floor(sec / 60) + '分')
  document.getElementById('restTime').innerHTML = text

HeaderBar.updateLookingBackTimeNotification = ->
  getIsLookingBackTime = ->
    minutes = new Date().getMinutes()
    return (25 <= minutes && minutes <= 30) || 55 <= minutes
  isLookingBackTime = getIsLookingBackTime()
  labelElement = document.getElementById('looking-back-time')
  labelVisible = labelElement.className != 'none'
  if(isLookingBackTime != labelVisible)
    labelElement.className = if isLookingBackTime then '' else 'none'
