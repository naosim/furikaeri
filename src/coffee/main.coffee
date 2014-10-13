###
note
  Element: DOM。HTMLElement。
  View: 概念的なビュー。DOM操作する。
###

String.prototype.replaceAll = (before, after) -> this.split(before).join(after)

(() ->
  putZero = (num) -> if parseInt(num, 10) < 10 then '0' + num else num
  createTableRowsView = ->
    # 7〜19時の25分と55分をコールバックでかえす
    forInterval = (callback) ->
      for i in [6..23]
        i = putZero(i)
        callback(i, 25)
        callback(i, 55)

    key = (h, m) -> "#{h}_#{m}"
    contentId = (h, m) -> "content_#{key(h, m)}"
    rowId = (h, m) -> "rowId_#{key(h, m)}"
    doneButtonId = (h, m) -> "doneButtonId_#{key(h, m)}"

    # views
    tableElement = document.getElementsByTagName('table')[0]
    visibleAllButtonElement = document.getElementById('visibleAllButton')
    visibleNowButtonElement = document.getElementById('visibleNowButton')
    getContentTextAreaElement = (h, m) -> document.getElementById(contentId(h, m))
    getRow = (h, m) ->
      return {
        setVisible: (visible) ->
          document.getElementById(rowId(h, m)).style['display'] = if visible then 'block' else 'none'
      }
    getDoneButton = (h, m) ->
      buttonElement = document.getElementById(doneButtonId(h, m))
      pomoImageElement = document.getElementById(doneButtonId(h, m)).querySelector('img')
      isDone = (pomoImageElement) -> pomoImageElement.className.indexOf('not-done') == -1
      return {
        init: ->
          buttonElement.addEventListener('click',() => this.setDone(!this.isDone()))
        isDone:-> isDone(pomoImageElement)
        setDone: (done) -> pomoImageElement.className = if done then 'pomo' else 'pomo not-done'
      }

    init = ->
      template = document.getElementById('rowTemplate').innerHTML
      tableRows = ''
      # テンプレートの適用
      forInterval((h, m) ->
        startMinute = putZero(Math.floor(m/30) * 30) # 00 or 30
        tableRows += template
          .replaceAll('$$rowId$$', rowId(h, m))
          .replaceAll('$$time$$', "#{h}:#{startMinute}<br>|<br>#{h}:#{m}")
          .replaceAll('$$content$$', "<textarea id=\"#{contentId(h, m)}\"></textarea>")
          .replaceAll('$$doneButtonId$$', doneButtonId(h, m))
      )
      tableElement.innerHTML = tableRows
      forInterval((h, m) -> getDoneButton(h, m).init())
      visibleAllButtonElement.addEventListener('click', () => this.visibleAll())
      visibleNowButtonElement.addEventListener('click', () => this.optVisible())

    setData = (dataList) ->
      forInterval((h, m) ->
        data = dataList[key(h, m)]
        getContentTextAreaElement(h, m).value = if data then data.content || '' else ''
        getDoneButton(h, m).setDone(if data then data.isDone else false)
      )

    getData = ->
      result = {}
      forInterval((h, m) ->
        result[key(h, m)] = {
          content: getContentTextAreaElement(h, m).value
          isDone: getDoneButton(h, m).isDone()
        }
      )
      return result

    # 現在時刻のみ表示
    optVisible = () ->
      date = new Date()
      isNow = (h) -> date.getHours() - 1 <= h && h <= date.getHours() + 1
      forInterval((h, m) -> getRow(h, m).setVisible(isNow(h)))
      visibleAllButtonElement.style['display'] = 'block'
      visibleNowButtonElement.style['display'] = 'none'

    # すべて時間を表示する
    visibleAll = ->
      forInterval((h, m) -> getRow(h, m).setVisible(true))
      visibleAllButtonElement.style['display'] = 'none'
      visibleNowButtonElement.style['display'] = 'block'

    # public methods
    return {
      init: init
      setData: setData
      getData: getData
      optVisible: optVisible
      visibleAll: visibleAll
    }

  createDataIO = ->
    DATA_LIST_KEY = 'dataList'
    return {
      load: ->
        orgDataList = localStorage[DATA_LIST_KEY]
        return if orgDataList then JSON.parse(orgDataList) else {}
      save: (dataList) -> localStorage[DATA_LIST_KEY] = JSON.stringify(dataList)
    }

  # 画面右上の時間表示部分
  updateTimeDisplay = ->
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
    text = "#{putZero(now.getHours())}:#{putZero(now.getMinutes())}<br>" + 'ふりかえりまで<br>あと ' + (if sec < 60 then sec + '秒' else Math.floor(sec / 60) + '分')
    document.getElementById('restTime').innerHTML = text

  updateLookingBackTimeNotification = ->
    getIsLookingBackTime = ->
      minutes = new Date().getMinutes()
      return (25 <= minutes && minutes <= 30) || 55 <= minutes
    isLookingBackTime = getIsLookingBackTime()
    lookingBackTimeLabelElement = document.getElementById('looking-back-time')
    labelVisible = lookingBackTimeLabelElement.className != 'none'
    if(isLookingBackTime != labelVisible)
      label.className = if isLookingBackTime then '' else 'none'

  save = -> dataIO.save(tableRowsView.getData())
  startAutoSave = (saveInterval) -> setInterval((-> save()), saveInterval)

  # メイン
  dataIO = createDataIO()
  tableRowsView = createTableRowsView()
  tableRowsView.init()
  tableRowsView.setData(dataIO.load())
  tableRowsView.optVisible()
  startAutoSave(3 * 60 * 1000)
  allClear = () ->
    tableRowsView.setData({})
    save()
  document.getElementById('allClearButton').addEventListener('click', allClear)

  # ctrl + s -> save
  document.addEventListener('keydown', (e) ->
    KEY_CODE_S = 83
    isCtrlS = (e) -> (e.ctrlKey || e.metaKey) && e.keyCode == KEY_CODE_S
    if isCtrlS(e)
      save()
      alert('saved!')
      # ブラウザの保存を発火させない
      e.returnValue = false
  )

  setInterval(->
    updateTimeDisplay()
    updateLookingBackTimeNotification()
  ,1000)
)()
