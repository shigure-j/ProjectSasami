window.ajaxRequest = function (params) {
  $.get(url + '?' + $.param(params.data)).then(function (res) {
    params.success(res)
  })
}
