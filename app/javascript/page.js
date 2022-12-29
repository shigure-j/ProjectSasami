window.onpageshow = function() {
    // Clipboard
    var clipboard = new ClipboardJS(".btn")
    clipboard.on('success', function(e) {
        console.info('Action:', e.action);
        console.info('Text:', e.text);
        console.info('Trigger:', e.trigger);

        e.clearSelection();
    });
    // Popover
    $('body').popover({
        selector: '.focus-popover',
        trigger: 'hover focus'
    });
    //
    $.get("data")
    $.get("data?" + document.URL.split("?")[1])
}
    $.get("data")
    $.get("data?" + document.URL.split("?")[1])
