Date.prototype.format = function (fmt) { //author: meizz
    var o = {
        "M+": this.getMonth() + 1, //月份
        "d+": this.getDate(), //日
        "H+": this.getHours(), //小时
        "m+": this.getMinutes(), //分
        "s+": this.getSeconds(), //秒
        "q+": Math.floor((this.getMonth() + 3) / 3), //季度
        "S": this.getMilliseconds() //毫秒
    };
    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (var k in o)
    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
}

window.cellFormatter = function(type, opt) {
  switch (type) {
    case "int":
      return function(value) {
        return parseInt(value)
      }
    case "float":
      return function(value) {
        return parseFloat(value).toFixed(opt)
      }
    case "datetime":
      return function(value) {
        var dateObj = new Date(Date.parse(value))
        return dateObj.format(opt)
      }
    case "string":
      return function(value) {
        return value
      }
    case "path":
      return function(value) {
        return '<button type="button" class="btn btn-secondary focus-popover" data-clipboard-action="copy" data-bs-container="body" data-bs-toggle="popover" data-bs-placement="top" data-bs-trigger="hover focus" data-clipboard-text="' + value + '" data-bs-content="' + value + '"> copy </button>'
      }
    default:
      return function(value) {
        return value
      }
  }
}

window.setColAsGroup = function(row, element, field, table) {
  if (table.getOptions().groupBy && table.getOptions().groupByField == field) {
    table.refreshOptions({groupBy: false})
  } else {
    table.refreshOptions({groupBy: true, groupByField: field, groupByToggle: true, groupByShowToggleIcon: true})
  }
}

window.replaceParamVal = function(paramName,replaceWith) {
  var oUrl = this.location.href.toString();
  var re=eval('/('+ paramName+'=)([^&]*)/gi');
  var nUrl = oUrl.replace(re,paramName+'='+replaceWith);
  //this.location = nUrl;
  //window.location.href=nUrl
  history.replaceState(0,0,nUrl);
}

window.loadWork = function(incr, redirect) {
  $table = $('#dashboard_view')
  org_ids = []
  if (incr) {
    $("#work_table").bootstrapTable("getVisibleColumns").forEach(function(v) {
      id = v.field;
      if (typeof id == 'number') {
        org_ids.push(id)
      }
    })
  }
  work_ids = org_ids.concat($table.bootstrapTable('getSelections').map(function(row) {
    return row.id
  }))
  if (redirect) {
    window.location.href="detail?works=" + work_ids.join(",")
  } else {
    replaceParamVal("works", work_ids.join(","))
    $.get("data?works="+ work_ids.join(","))
  }
}

window.loadWorks = function() {
  $table = $('#dashboard_view')
  work_ids = $table.bootstrapTable('getSelections').map(function(row) {
    return row.id
  })
  $.get("data?works="+ work_ids.join(",")).then (
    function (res) {
      $("#work_table").bootstrapTable("destroy")
      $("#work_table").bootstrapTable(res)
      //$("#work_table").bootstrapTable(`refreshOptions(${res})`)
    }
  )
}

window.loadSum = function(param) {
  $.get("data?" + param).then (
    function (res) {
      eval(res)
    }
  )
}
