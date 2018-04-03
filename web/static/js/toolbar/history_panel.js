import $ from '../lib/jquery';

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
      event.preventDefault();
      callback($(this).data('uuid'));
    });
    this.toolbar.on("click", ".back-to-current-request", function(event) {
      event.preventDefault();
      callback(requestId);
    });
  }
}

export default HistoryPanel;
