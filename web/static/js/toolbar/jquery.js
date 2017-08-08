// Bootstrap expects a global jQuery object, which leads to a clash
// between user's app and toolbar jQuery.


// 1. import jQuery from toolbar's package
import $ from 'jquery';

// 2. stash global jQuery if present
const _jQuery = window.jQuery;
const _$ = window.$;

// 3. make toolbar's jQuery global
window.jQuery = $;
window.$ = $;

// 4. import bootstrap that adds plugins to global jQuery
require('bootstrap-sass');

// 5. make stashed jQuery global again
window.jQuery = _jQuery;
window.$ = _$;

export default $;
