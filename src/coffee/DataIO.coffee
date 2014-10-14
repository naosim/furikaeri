DataIO = {}
DataIO.create = ->
  DATA_LIST_KEY = 'dataList'
  return {
    load: ->
      orgDataList = localStorage[DATA_LIST_KEY]
      return if orgDataList then JSON.parse(orgDataList) else {}
    save: (dataList) -> localStorage[DATA_LIST_KEY] = JSON.stringify(dataList)
  }
