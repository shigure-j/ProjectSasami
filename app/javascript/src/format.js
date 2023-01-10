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

window.cellFormatter = function(type, opt, add) {
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
    case "image":
      return function(value, row, index, field) {
        return add[field][value.split(":")[1]]
      }
    case "boolean":
      return function(value) {
        if (value == "true" || value == "1") {
          return '<i class="bi bi-check-circle-fill">true</i>'
        } else {
          return '<i class="bi bi-x-circle">false</i>'
        }
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
  if(oUrl.split("?")[1].match(paramName + "=")) {
    var re=eval('/('+ paramName+'=)([^&]*)/gi');
    var nUrl = oUrl.replace(re,paramName+'='+replaceWith);
  } else {
    var nUrl = oUrl + "&" + paramName + "=" + replaceWith
  }
  //this.location = nUrl;
  //window.location.href=nUrl
  history.replaceState(0,0,nUrl);
}

window.editWork = function() {
  $table = $('#dashboard_view')
  work_ids = $table.bootstrapTable('getSelections').map(function(row) {return row.id})
  switch($("input[name='edit_option']:checked").val()) {
    case "delete":
      $("#edit_result").attr("src", "/data/delete?works="+ work_ids.join(","))
      break;
    case "public":
      $("#edit_result").attr("src", "/data/edit?is_private=0&works="+ work_ids.join(","))
      break;
    case "private":
      $("#edit_result").attr("src", "/data/edit?is_private=1&works="+ work_ids.join(","))
      break;
  }
}

window.detailTableButtons = function() {
  return {
      //text: 'Show By Page',
    btnSwitchPage: {
      icon: 'bi-file-earmark-break',
      event: function () {
        if (window.location.toString().match("pagination=1")) {
          replaceParamVal("pagination", 0)
        } else {
          replaceParamVal("pagination", 1)
        }
        window.location=window.location.href
      },
      attributes: {
        title: 'Show By Page'
      }
    }
  }
}

window.changeSub = function(sub) {
  replaceParamVal("sub", sub)
  $.get("/data/work?" + this.location.href.split("?")[1])
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
    $.get("/data/work?works="+ work_ids.join(","))
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

window.getSummary = function(params) {
  $.get("/data/summary?" + params.data).then(function(res) {
    params.success(res)
  })
}

window.loadSum = function(param) {
  $.get("data?" + param).then (
    function (res) {
      eval(res)
    }
  )
}
window.modalView = function(content) {
  $("#modal_view").replaceWith(content)
  const myModalAlternative = new bootstrap.Modal('#modal_view_div')
  myModalAlternative.show()
  //myModalAlternative.addEventListener('shown.bs.modal', () => {
  //  myInput.focus()
  //})
}
