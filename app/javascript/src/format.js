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
