###
note
  Element: DOM。HTMLElement。
  View: 概念的なビュー。DOM操作する。
###

(() ->
  save = -> dataIO.save(tableRowsView.getData())
  startAutoSave = (saveInterval) -> setInterval((-> save()), saveInterval)

  # メイン
  dataIO = DataIO.create()
  tableRowsView = TableRowsView.create()
  tableRowsView.init()
  tableRowsView.setData(dataIO.load())
  tableRowsView.optVisible()
  startAutoSave(3 * 60 * 1000)
  allClear = (tableRowsView, save) ->
    return ->
      tableRowsView.setData({})
      save()
  document.getElementById('allClearButton').addEventListener('click', allClear(tableRowsView, save))

  # ctrl + s -> save
  saveByCtrlS = (save) ->
    KEY_CODE_S = 83
    isCtrlS = (e) -> (e.ctrlKey || e.metaKey) && e.keyCode == KEY_CODE_S
    return (e) ->
      if isCtrlS(e)
        save()
        alert('saved!')
        # ブラウザの保存を発火させない
        e.returnValue = false
  document.addEventListener('keydown', saveByCtrlS(save))

  setInterval(->
    HeaderBar.updateTimeDisplay()
    HeaderBar.updateLookingBackTimeNotification()
  ,1000)
)()
