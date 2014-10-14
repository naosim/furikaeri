TableRowsView = {}
TableRowsView.create = ->
  # 7〜19時の25分と55分をコールバックでかえす
  forInterval = (callback) ->
    for i in [6..23]
      i = Utils.putZero(i)
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
  getRowView = (h, m) ->
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
      startMinute = Utils.putZero(Math.floor(m/30) * 30) # 00 or 30
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
    forInterval((h, m) -> getRowView(h, m).setVisible(isNow(h)))
    visibleAllButtonElement.style['display'] = 'block'
    visibleNowButtonElement.style['display'] = 'none'

  # すべて時間を表示する
  visibleAll = ->
    forInterval((h, m) -> getRowView(h, m).setVisible(true))
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
