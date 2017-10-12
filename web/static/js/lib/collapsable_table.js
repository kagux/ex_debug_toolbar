import $ from './jquery';

class CollapsableTable {
  constructor(table) {
    this.table = table;
  }

  render() {
    this.addEventListeners();
  }

  addEventListeners() {
    this.table.on("click", ".rows-expand, .rows-collapse", function(event) {
      console.log("click");
      event.preventDefault();
      event.stopPropagation();
      const tr = $(this).closest('tr')
      tr.nextUntil('.visible-row').fadeToggle();
      tr.find('.rows-expand').toggle();
      tr.find('.rows-collapse').toggle();
    });
  }
}

export default CollapsableTable;
