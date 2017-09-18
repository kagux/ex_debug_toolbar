import $ from './jquery';

class HistoryPanel {
  constructor(toolbar, requestId, callback) {
    this.toolbar = toolbar;
    this.addEventListeners(callback, requestId);
  }

  render(requestId) {
    this.toolbar.find('.history-point').removeClass('active');
    this.toolbar.find(`.history-point[data-uuid="${requestId}"]`).toggleClass('active');
  }

  addEventListeners(callback, requestId) {
    this.toolbar.on("click", ".history-point:not(.active)", function(event) {
      console.log('history click');
      event.preventDefault();
      callback($(this).data('uuid'));
    });
    this.toolbar.on("click", ".back-to-current-request", function(event) {
      event.preventDefault();
      callback(requestId);
    });
    this.toolbar.on("click", ".history-expand, .history-collapse", function(event) {
      event.preventDefault();
      event.stopPropagation();
      const tr = $(this).closest('tr')
      tr.nextUntil('.last-request').fadeToggle();
      tr.find('.history-expand').toggle();
      tr.find('.history-collapse').toggle();
    });
  }
}

export default HistoryPanel;
