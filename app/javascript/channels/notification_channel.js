import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    id = "notifi_toast" + $(".my_toast_marker").size()
    if (data.timeout == 0) {
      attr = 'data-bs-autohide="false"'
    } else {
      attr = ' data-bs-delay="' + data.timeout + '" '
    }
    new_toast  = ""
    new_toast += '<div id="' + id + '" ' + attr + ' class="toast my_toast_marker" role="alert" aria-live="assertive" aria-atomic="true">'
    new_toast += '  <div class="toast-header">'
    new_toast += '    <strong class="me-auto">' + data.title + '</strong>'
    new_toast += '    <small class="text-muted">' + data.time + '</small>'
    new_toast += '    <div class="btn-group" role="group">'
    //new_toast += '      <button type="button" class="bi bi-chevron-bar-down" title="Close All" onclick="$(\'.my_toast_marker\').remove();"></button>'
    new_toast += '      <button type="button" class="btn px-1" title="Close All" onclick="$(\'.my_toast_marker\').remove();">'
    new_toast += '        <i class="bi bi-chevron-bar-down"></i>'
    new_toast += '      </button>'
    new_toast += '      <button type="button" class="btn px-1" data-bs-dismiss="toast" title="Close" aria-label="Close">'
    new_toast += '        <i class="bi bi-chevron-bar-right"></i>'
    new_toast += '      </button>'
    new_toast += '    </div>'
    new_toast += '  </div>'
    new_toast += '  <div class="toast-body">'
    new_toast += data.body
    new_toast += '  </div>'
    new_toast += '</div>'
    $("#notifi_container").append(new_toast)
    const toast = new bootstrap.Toast(document.getElementById(id))
    toast.show()
  }
});
