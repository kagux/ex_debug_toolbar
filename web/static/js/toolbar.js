import {Socket} from 'phoenix';
import $ from './lib/jquery';
import Logger from './lib/logger';
import BreakpointsPanel from './toolbar/breakpoints_panel';
import HistoryPanel from './toolbar/history_panel';
import Highlight from './lib/highlight';

class App {
  constructor(opts) {
    this.logger = new Logger(opts.debug)
    this.originalRequestId = opts.requestId;
    this.resetActivePanel();
    this.socket = this.initSocket();
    this.toolbar = $("<div>", {id: "ex-debug-toolbar"});
    this.breakpointsPanel = new BreakpointsPanel(this.socket, this.toolbar);
    this.historyPanel = new HistoryPanel(this.toolbar, this.originalRequestId, this.render.bind(this));
    this.highlight = new Highlight;
    $("body").append(this.toolbar);
  }

  render(requestId) {
    this.logger.debug('Rendering request', requestId)
    this.joinToolbarChannel(this.socket, requestId);
  }

  initSocket() {
    const socket = new Socket("/__ex_debug_toolbar__/socket");
    socket.connect();
    return socket;
  }

  joinToolbarChannel(socket, requestId) {
    this.logger.debug('Joining channel', requestId)
    const channel = socket.channel(`toolbar:request:${requestId}`)
    channel
    .join()
    .receive("ok", this.onChannelResponse.bind(this))
    .receive("error", resp => {
      this.logger.debug('Unable to join channel', resp)
    });

    channel.on("request:created", this.onChannelResponse.bind(this));
  }

  onChannelResponse(response){
    if (response.html) {
      this.logger.debug('Received response from channel')
      this.renderToolbar(response);
    } else {
      this.logger.debug('Waiting for request to be processed')
    }
  }

  renderToolbar({html: html, uuid: uuid, request: request}){
    this.logger.debug('Request data', request)
    const content = $('<div>').html(html);
    if (this.originalRequestId != uuid) {
      this.logger.debug('Historic request');
      content.addClass("historic-request");
    }
    this.toolbar.html(content);
    this.renderPanels(this.toolbar);
    this.renderPopovers(this.toolbar);
    this.breakpointsPanel.render(uuid);
    this.historyPanel.render(uuid);
    this.highlight.render(this.toolbar);
  }

  renderPanels(toolbar) {
    toolbar
    .mouseleave(this.hideActivePanel.bind(this))
    .find('[data-toggle="panel"]')
    .hover(this.showPanel.bind(this));

    toolbar
    .find('.panel-body')
    .on( 'mousewheel DOMMouseScroll', this.scrollDivOnly);
  }

  scrollDivOnly(event) {
    event.preventDefault();
    const original = event.originalEvent;
    const delta = original.wheelDelta || -original.detail;
    this.scrollTop -= delta;
  }

  hideActivePanel() {
    if(this.activePanel){
      this.activePanel.slideUp(150);
      this.resetActivePanel();
    }
  }

  showPanel({target: target}) {
    const panel = $(target).parent().find('.panel');
    const id = this.getPanelId(panel);
    if (this.activePanelId != id) {
      panel.slideDown(150);
      if(this.activePanel) this.activePanel.slideUp(50);
      this.activePanel = panel;
      this.activePanelId = id;
    }
  }

  resetActivePanel() {
    this.activePanel = null;
    this.activePanelId = null;
  }

  getPanelId(panel) {
    if (!panel.data('panel-id')) {
      const id = Math.round(new Date().getTime() + (Math.random() * 100));
      panel.data('panel-id', id);
    }
    return panel.data('panel-id');
  }

  renderPopovers(toolbar) {
    $(toolbar).find('[data-toggle="popover"]').popover();
  }
}
const opts = window.ExDebugToolbar;
(new App(opts)).render(opts.requestId);
