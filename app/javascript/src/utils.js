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
        if (value.upstream_id == undefined) {
          upstream = `<a type="button" class='btn btn-secondary bi bi-chevron-left focus-popover disabled'></a>`
          upstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-double-left focus-popover disabled'></a>`
        } else {
          upstream = `<a type="button" class='btn btn-secondary bi bi-chevron-left focus-popover' data-turbo='false' href='/detail?works=${value.upstream_id}' data-bs-placement='top' data-bs-title='Upstream' data-bs-content='Click to show upstream work: ${value.upstream}'></a>`
          upstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-double-left focus-popover' data-turbo='false' onclick='traceRelated("up", ${value.id})' data-bs-placement='top' data-bs-title='Ancestors' data-bs-content='Click to list ${value.upstreams_size} ancestor works'></a>`
        }
        if (value.downstreams_size == 0) {
          downstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-bar-right focus-popover disabled'></a>`
        } else {
          downstreams = `<a type="button" class='btn btn-secondary bi bi-chevron-bar-right focus-popover' data-turbo='false' onclick='traceRelated("down", ${value.id})' data-bs-placement='top' data-bs-title='Downstreams' data-bs-content='Click to list ${value.downstreams_size} downstream works'></a>`
        }
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
  switchSummaryFlag = 2
  switchSummary(0, new_url)
  offcavasTitle = $("#offcanvasLabel")
  if (offcavasTitle.size()) {
    offcavasTitle.text("Related Works")
  }
}

window.getQueryString = function(name) {
  var query_string = window.location.search
  if (!query_string) return null; // 如果无参，返回null
  var re = /[?&]?([^=]+)=([^&]*)/g;
  var tokens;
  while (tokens = re.exec(query_string)) {
    if (decodeURIComponent(tokens[1]) === name) {
      return decodeURIComponent(tokens[2]);
    }
  }
  return null;
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
  if ($("#chart_box").size() !== 0) {
    var work_ids = getChartSelected()
  } else {
    var work_ids = getSummarySelected(0)
  }
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
    case "upstream":
      up_id = $("#upstream_id")[0].value
      $("#edit_result").attr("src", "/data/edit?upstream=" + up_id + "&works=" + work_ids.join(","))
      break;
  }
}

window.sumTableButtons = function() {
  return {
    btnRefresh: {
      icon: 'bi-arrow-clockwise',
      event: function () {
        switchSummaryFlag = 1
        switchSummary(0)
      },
      attributes: {
        title: 'Reset'
      }
    }
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
  focus_param = $li.toArray().map((i) => {return escape(i.textContent)}).join(",")
  replaceParamVal("focus", focus_param)
  window.location=window.location.href
}

window.changeSub = function(sub) {
  if (event.button == 1) {
    org_subs = getQueryString("sub")
    if (org_subs == null) {
      replaceParamVal("sub", escape(sub))
    } else {
      subs = org_subs.split(",")
      if (subs.filter(i => i == escape(sub)).length >= 1) {
        // off
        new_subs = subs.filter(i => i !== escape(sub)).join(",")
        if (new_subs.length == 0) {
          return
        }
      } else {
        // on
        new_subs = org_subs + "," + escape(sub)
      }
      replaceParamVal("sub", new_subs)
    }
  } else if (event.button == 0) {
    replaceParamVal("sub", escape(sub))
  } else {
    return
  }
  replaceParamVal("focus", "")
  $.get("/data/work?" + this.location.href.split("?")[1]).then(detailTable)
}

window.getSummarySelected = function(incr) {
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
  selected_works = $table.bootstrapTable('getSelections').map(row => {return row.id})
  if (incr == 2) {
    return org_ids.filter(i => selected_works.indexOf(i) == -1)
  } else {
    return org_ids.concat(selected_works)
  }
}

window.loadWork = function(incr, redirect, chart) {
  if ($("#chart_box").size() !== 0) {
    var work_ids = getChartSelected()
  } else {
    var work_ids = getSummarySelected(incr)
  }
  if (redirect) {
    window.location.href="/detail?works=" + work_ids.join(",")
  } else if (chart) {
    if (work_ids.length > 0) {
      window.location.href="/chart?works=" + work_ids.join(",")
    } else {
      window.location.href="/chart"
    }
  } else {
    replaceParamVal("works", work_ids.join(","))
    $table.bootstrapTable("uncheckAll")
    $.get("/data/work?works="+ work_ids.join(",")).then(detailTable)
  }
}

window.switchSummary = function(current, new_url) {
  if (current && switchSummaryFlag !== current) {
    switchSummaryFlag = 1
    $("#offcanvasLabel").text("Current Works")
    $("#dashboard_view").bootstrapTable('clearFilterControl')
    $('#dashboard_view').bootstrapTable('refreshOptions', {url: null, data: current_work_table, sidePagination: "client", pageNumber: 1, sortPriority: null, sortName: null})
  } else if (!current && switchSummaryFlag) {
    switchSummaryFlag = 0
    if (new_url == undefined) {
      new_url = "/data/summary"
    }
    $("#offcanvasLabel").text("Select Works")
    $("#dashboard_view").bootstrapTable('clearFilterControl')
    $('#dashboard_view').bootstrapTable('refreshOptions', {url: new_url, sidePagination: "server", pageNumber: 1, sortPriority: null, sortName: null})
  }
}

window.modalView = function(content) {
  $("#modal_view").replaceWith(content)
  const myModalAlternative = new bootstrap.Modal('#modal_view_div')
  myModalAlternative.show()
  //myModalAlternative.addEventListener('shown.bs.modal', () => {
  //  myInput.focus()
  //})
}

window.createNode = function($node, data) {
  var id = data.id
  if (data.stage == 'design') {
    var prefix = 'expand_chart_design_'
    var url = "/data/chart?incr=1&design="
    var design_flag = true
  } else {
    var prefix = 'expand_chart_work_'
    var url = "/data/chart?incr=1&works="
    var design_flag = false
  }
  var secondMenuIcon = $('<i>', {
    'id': prefix + id,
    'class': 'bi bi-plus-circle-fill',
    'style': "position: absolute;right: 35px;bottom: -10px;z-index: 2;",
    click: function() {
      $.get(url + id).then(res => {
        if (design_flag) {
          res_data = res
        } else {
          res_data = res[id]
        }
        if (res_data !== undefined && res_data !== null) {
          $chart.addChildren($node, res_data)
        }
      })
      $("#" + prefix + id).remove()
    }
  });
  if (data.expand) {
    $node.append(secondMenuIcon)
  }
}

window.nodeTemplate = function(data) {
  var title_class = 'bg-primary'
  var extra = ''
  switch (data.stage) {
    case 'project':
      title_class = 'bg-info-subtle'
      break
    case 'design':
      title_class = 'bg-info'
      break
    default:
      if (data.name == '') {
        break
      }
      var date = new Date(Date.parse(data.created_at))
      var fmt_date = date.format("yyyy/MM/dd HH:mm")
      var content = `
        <p class='bi my-1 bi-list-ol'> ${data.id}</p>
        <p class='bi my-1 bi-person'> ${data.owner}</p>
        <p class='bi my-1 bi-clock'> ${fmt_date}</p>
      `
      extra = `class="focus-popover" data-bs-toggle="popover" data-bs-html="true" data-bs-title="${data.name}" data-bs-content="${content}"`
      break
  }
  return `
    <div onclick="chartSelect(this)" style="height: 130px" ${extra}>
      <div class="title ${title_class}">${data.stage}</div>
      <div class="content text-truncate" style="border: 0px">${data.name}</div>
    </div>
  `
}

window.initChart = function(data) {
  $box = $("#chart_box")
  $box.empty()
  $chart = $box.orgchart({
    data: data,
    direction: "l2r",
    parentNodeSymbol: "",
    nodeTemplate: nodeTemplate,
    createNode: createNode,
    pan: true,
    zoom: true
  })
  $('.orgchart').addClass('noncollapsable');
}

window.chartSelect = function(obj) {
  var type = $(obj).children(".title").text()
  switch (type) {
    case '':
      window.location.href="/chart"
      break
    case 'project':
      window.location.href="/chart?project=" + $(obj).parent().attr("id")
      break
    case 'design':
      window.location.href="/chart?design=" + $(obj).parent().attr("id")
      break
    default:
      var $content = $(obj).children(".content")
      $content.toggleClass("bg-primary text-light chart-work-selected")
      break
  }
}

window.getChartSelected = function() {
  return $(".chart-work-selected").parent("div").parent(".node").map((i, obj) => {return obj.id}).toArray()
}

window.detailTable = function(data) {
/*
 * data:
 *  userPayload:
 *    subs
 *    keys
 */
//TODO Formmater

  $table = $("#work_table")
  $nav = $("#sub_tables_nav")

  var sub_tables = data.userPayload.subs
  var sub_tables_names = Object.keys(sub_tables)
  window.current_work_table = data.userPayload.summary
  var table_keys = data.userPayload.keys
  delete data.userPayload
  var table_opt  = data
  table_opt["height"] = window.innerHeight - 100
  $table.bootstrapTable("destroy")
  $table.bootstrapTable(table_opt)

  if (sub_tables_names.length > 6) {
    var active_subs = Object.entries(sub_tables).map(i => {if(i[1]) {return i[0]}}).filter(i => i !== undefined).join(",")
    $nav.replaceWith('<div id="sub_tables_nav" class="dropdown"></div>')
    $nav = $("#sub_tables_nav")
    $nav.append(`<button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">Table: ${active_subs} </button>`)
    $nav.append('<ul id="sub_table_dropdown" class="dropdown-menu"></ul>')
    $dropdown = $("#sub_table_dropdown")
    sub_tables_names.forEach(n_table => {
      if (sub_tables[n_table]) {
        var active_flag = "active"
      } else {
        var active_flag = ""
      }
      $dropdown.append(`<li ><a class="dropdown-item ${active_flag}" onmouseup="changeSub('${n_table}')">${n_table}</a></li>`)
    })
  } else {
    $nav.replaceWith('<ul class="nav nav-tabs" id="sub_tables_nav"></ul>')
    $nav = $("#sub_tables_nav")
    sub_tables_names.forEach(n_table => {
      if (sub_tables[n_table]) {
        var active_flag = "active"
      } else {
        var active_flag = ""
      }
      $nav.append(`<li class="nav-item"><a role="button" class="nav-link ${active_flag}" onmouseup="changeSub('${n_table}')">${n_table}</a></li>`)
    })
  }

  $focus_sel = $("#focusSelect")
  $("#focusKeyList").empty()
  $focus_sel.empty()
  table_keys.forEach(key => {
    window.addFocusKeyOption(key)
  })
}
/*
window.setColAsGroup = function(row, element, field, table) {
  if (table.getOptions().groupBy && table.getOptions().groupByField == field) {
    table.refreshOptions({groupBy: false})
  } else {
    table.refreshOptions({groupBy: true, groupByField: field, groupByToggle: true, groupByShowToggleIcon: true})
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
*/
