import $ from './lib/jquery';
window.$ = $;
window.jQuery = $;
import CollapsableTable from './lib/collapsable_table';
require('admin-lte');

class App {
  render() {
    const table = new CollapsableTable($('#requests-history'));
    table.render();
  }
}

(new App()).render();
