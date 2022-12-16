import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery

jQuery.fn.extend( {
	size: function() {
        return this.length
    }
} )
