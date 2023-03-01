window.onpageshow = function() {
    // Clipboard
    var clipboard = new ClipboardJS(".btn")
    clipboard.on('success', function(e) {
        //console.info('Action:', e.action);
        //console.info('Text:', e.text);
        //console.info('Trigger:', e.trigger);

        $('#copied_toast').toast("show")
        e.clearSelection();
    });
    // Popover
    $('body').popover({
        selector: '.focus-popover',
        trigger: 'hover focus'
    });
    // Tooltip
    //$('body').tooltip({
    //    selector: '.tooltip'
    //});
    //$.get("data")
    if ($("#dashboard_view").size() != 0) {
        $("#dashboard_view").bootstrapTable()
    }
    if ($("#work_table").size() != 0) {
        $("#summary_button").addClass("active")
        $("#current_button").addClass("active")
        $.get("/data/work?" + document.URL.split("?")[1]).then(data => {
            detailTable(data)
            $("#summary_button").removeClass("active")
            $("#current_button").removeClass("active")
        })
    }
    switchSummaryFlag = 0
}
