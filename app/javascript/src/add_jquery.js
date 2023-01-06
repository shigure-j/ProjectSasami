import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery
export default $

jQuery.fn.extend( {
	size: function() {
        return this.length
    }
} )
