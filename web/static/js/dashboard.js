import {Socket} from 'phoenix';
import $ from './lib/jquery';
import Logger from './lib/logger';
window.$ = $;
window.jQuery = $;

require('admin-lte');

class App {
  constructor(opts) {
    console.log(opts);
    this.logger = new Logger(opts.debug)
    this.socket = this.initSocket();
    this.requestCountEl = $('#requests-count');
    this.requestsCount = parseInt(this.requestCountEl.text(), 10);
  }

  render() {
    this.logger.debug('Rendering dashboard')
    this.joinToolbarChannel(this.socket);
    $("#requests-history").on("click", "tr", this.onRequestClick);
    this.renderTooltips();
  }

  initSocket() {
    const socket = new Socket("/__ex_debug_toolbar__/socket");
    socket.connect();
    return socket;
  }

  joinToolbarChannel(socket) {
    this.logger.debug('Joining dashboard channel')
    const channel = socket.channel('dashboard:history')
    channel
    .join()
    .receive("ok",  resp => {
      this.logger.debug('Successfully joined channel', resp)
    })
    .receive("error", resp => {
      this.logger.debug('Unable to join channel', resp)
    });

    channel.on("request:created", this.onRequestCreated.bind(this));
    channel.on("request:deleted", this.onRequestDeleted.bind(this));
  }

  onRequestDeleted(data){
    this.logger.debug('Deleting request', data.uuid);
    $(`#${data.uuid}`).remove();
    this.requestCountEl.text(--this.requestsCount);
  }

  onRequestCreated(data){
    this.logger.debug('Adding request', data.request.uuid, data.request);
    $(data.html).prependTo('#requests-history > tbody');
    this.requestCountEl.text(++this.requestsCount);
    this.renderTooltips();
    if (this.requestsCount == 1) {
      $('#no-requests-history').hide();
      $('#requests-history-container').removeClass('hidden');
    }
  }

  onRequestClick() {
    const id = $(this).attr("id");
    window.location = "/__ex_debug_toolbar__/requests/" + id;
  }

  renderTooltips() {
    $('[data-toggle="tooltip"]').tooltip();
  }
}

const opts = window.ExDebugToolbar || {};
(new App(opts)).render();
