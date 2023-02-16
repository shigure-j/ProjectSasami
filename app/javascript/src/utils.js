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
        return '<button type="button" class="btn btn-secondary focus-popover bi bi-clipboard" data-clipboard-action="copy" data-bs-container="body" data-bs-toggle="popover" data-bs-placement="top" data-bs-trigger="hover focus" data-clipboard-text="' + value + '" data-bs-content="' + value + '"></button>'
      }
    case "image":
      return function(value, row, index, field) {
        return add[field][value.split(":")[1]]
      }
    case "boolean":
      return function(value) {
        if (value == "true" || value == "1") {
          return '<i class="bi bi-check-circle-fill"></i>'
        } else {
          return '<i class="bi bi-x-circle"></i>'
        }
      }
    case "relationship":
      return function(value) {
        upstream = `<a type="button" class='btn btn-secondary bi bi-chevron-left focus-popover' data-turbo='false' href='/detail?works=${value.upstream_id}' data-bs-placement='top' data-bs-title='Upstream' data-bs-content='Click to show upstream work: ${value.upstream}'></a>`
        //upstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-double-left focus-popover' data-turbo='false' href='/summary?upstreams_of=${value.id}' data-bs-placement='top' data-bs-title='Ancestors' data-bs-content='Click to list ${value.upstreams_size} ancestor works'></a>`
        //downstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-bar-right focus-popover' data-turbo='false' href='/summary?downstreams_of=${value.id}' data-bs-placement='top' data-bs-title='Downstreams' data-bs-content='Click to list ${value.downstreams_size} downstream works'></a>`
        upstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-double-left focus-popover' data-turbo='false' onclick='traceRelated("up", ${value.id})' data-bs-placement='top' data-bs-title='Ancestors' data-bs-content='Click to list ${value.upstreams_size} ancestor works'></a>`
        downstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-bar-right focus-popover' data-turbo='false' onclick='traceRelated("down", ${value.id})' data-bs-placement='top' data-bs-title='Downstreams' data-bs-content='Click to list ${value.downstreams_size} downstream works'></a>`
        return ('<div class="btn-group" role="group">' + upstream + upstreams + downstreams + '</div>')
      }
    default:
      return function(value) {
        return value
      }
  }
}

window.traceRelated = function(up_down, id) {
  $table = $('#dashboard_view')
  if (up_down == "up") {
    new_url = "/data/summary?upstreams_of=" + id
  } else {
    new_url = "/data/summary?downstreams_of=" + id
  }
  $(".focus-popover").popover("hide") // W/A
  $table.bootstrapTable('refresh', {url: new_url})
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
    },
    btnExport: {
      icon: 'bi-download',
      event: function () {
        window.location= "/export.xlsx?" + window.location.href.toString().split("?")[1]
      },
      attributes: {
        title: 'Export To Excel'
      }
    },
    btnFocus: {
      icon: 'bi-magic',
      event: function () {
        $('#focusModal').modal("show")
      },
      attributes: {
        title: 'Focus on keys'
      }
    }
  }
}

window.addFocusKeyOption = function(key) {
  $('#focusSelect').append(`<option value="${key}">${key}</option>`)
}

window.addFocusKey = function() {
  sel_val = $("#focusSelect").val()
  if ($("#focusSelect option:selected").size() == 0) {
    return
  }
  $("#focusSelect option:selected").remove()
  add_el = `<li onclick="this.remove();window.addFocusKeyOption(this.textContent)" class="list-group-item" value="${sel_val}">${sel_val}</li>`
  $("#focusKeyList").append(add_el)
}

window.focusKeys = function() {
  $li = $("#focusKeyList li")
  focus_param = $li.toArray().map((i) => {return i.textContent}).join(",")
  replaceParamVal("focus", focus_param)
  window.location=window.location.href
}

window.changeSub = function(sub) {
  replaceParamVal("sub", sub)
  replaceParamVal("focus", "")
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
    window.location.href="/detail?works=" + work_ids.join(",")
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
