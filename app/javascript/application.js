// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"
import "./src/add_jquery"

import "jquery-ui/dist/jquery-ui.min"
import "jquery-resizable-columns"
import "dragtable"
//import "tablednd"
import ClipboardJS from "clipboard"
import * as bootstrap from "bootstrap"
import "bootstrap-table"
import "bootstrap-table/dist/extensions/reorder-columns/bootstrap-table-reorder-columns"
import "bootstrap-table/dist/extensions/filter-control/bootstrap-table-filter-control"
import "bootstrap-table/dist/extensions/toolbar/bootstrap-table-toolbar"
import "bootstrap-table/dist/extensions/resizable/bootstrap-table-resizable"
import "bootstrap-table/dist/extensions/group-by-v2/bootstrap-table-group-by"
import "bootstrap-table/dist/extensions/fixed-columns/bootstrap-table-fixed-columns"
import "bootstrap-table/dist/extensions/multiple-sort/bootstrap-table-multiple-sort"
//import "bootstrap-table/dist/extensions/sticky-header/bootstrap-table-sticky-header"
//import "bootstrap-table/dist/extensions/reorder-rows/bootstrap-table-reorder-rows"
import "./src/utils"

window.bootstrap = bootstrap
window.ClipboardJS = ClipboardJS
