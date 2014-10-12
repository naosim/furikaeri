String.prototype.replaceAll = (before, after) -> this.split(before).join(after)

(() ->
  createTableRowsView = ->
    putZero = (num) ->
      num = parseInt(num, 10)
      return if num < 10 then '0' + num else num

    forInterval = (callback) ->
      for i in [7..19]
        i = putZero(i)
        callback(i, 25)
        callback(i, 55)

    createKey = (h, m) -> "#{h}_#{m}"
    contentId = (h, m) -> "content_#{createKey(h, m)}"
    rowId = (h, m) -> "rowId_#{createKey(h, m)}"

    init = ->
      template = document.getElementById('rowTemplate').innerHTML
      tableRows = ''
      forInterval((h, m) ->
        key = createKey(h, m)
        startMinute = putZero(Math.floor(m/30) * 30)
        tableRows += template
          .replaceAll('$$rowId$$', rowId(h, m))
          .replaceAll('$$time$$', "#{h}:#{startMinute} - #{h}:#{m}")
          .replaceAll('$$content$$', "<textarea id=\"#{contentId(h, m)}\"></textarea>")
      )
      document.getElementsByTagName('table')[0].innerHTML = tableRows

      document.getElementById('visibleAllButton').addEventListener('click', () => this.visibleAll())
      document.getElementById('visibleNowButton').addEventListener('click', () => this.optVisible(new Date()))

    setData = (dataList) ->
      forInterval((h, m) ->
        key = createKey(h, m)
        data = dataList[key]
        document.getElementById(contentId(h, m)).value = if data then data else ''
      )

    getData = ->
      result = {}
      forInterval((h, m) ->
        key = createKey(h, m)
        result[key] = document.getElementById(contentId(h, m)).value
      )
      return result

    optVisible = (date) ->
      forInterval((h, m) ->
        row = document.getElementById(rowId(h, m))
        styleDisplay = if(h < date.getHours() - 1 || h > date.getHours() + 1) then "none" else "block"
        row.style['display'] = styleDisplay

        document.getElementById('visibleAllButton').style['display'] = 'block'
        document.getElementById('visibleNowButton').style['display'] = 'none'
      )

    visibleAll = ->
      forInterval((h, m) -> document.getElementById(rowId(h, m)).style['display'] = 'block')
      document.getElementById('visibleAllButton').style['display'] = 'none'
      document.getElementById('visibleNowButton').style['display'] = 'block'

    return {
      init: init
      setData: setData
      getData: getData
      optVisible: optVisible
      visibleAll: visibleAll
    }

  createDataIO = ->
    key = 'dataList'
    return {
      load: ->
        orgDataList = localStorage[key]
        return if orgDataList then JSON.parse(orgDataList) else {}
      save: (dataList) -> localStorage[key] = JSON.stringify(dataList)
    }

  save = -> dataIO.save(tableRowsView.getData())
  startAutoSave = (saveInterval) -> setInterval((-> save()), saveInterval)

  # メイン
  dataIO = createDataIO()
  tableRowsView = createTableRowsView()
  tableRowsView.init()
  tableRowsView.setData(dataIO.load())
  tableRowsView.optVisible(new Date())
  startAutoSave(3 * 60 * 1000)

  # ctrl + s -> save
  document.addEventListener('keydown', (e)->
    KEY_CODE_S = 83
    if (e.ctrlKey || e.metaKey) && e.keyCode == KEY_CODE_S
      console.log('ctrl + s -> saved')
      save()
      alert('saved!')
      e.returnValue = false
  )

)()
