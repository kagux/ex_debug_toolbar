import 'phoenix_html';
import {Socket} from 'phoenix';
import $ from "jquery";
import Highlight from "highlight.js";
window.jQuery = $;
require('bootstrap-sass');

class App {
  constructor(opts) {
    this.opts = opts;
    this.resetActivePanel();
  }

  render() {
    this.joinChannel();
  }

  joinChannel() {
    const socket = new Socket("/__ex_debug_toolbar__/socket");
    socket.connect();
    const channel = socket.channel(`toolbar:request:${this.opts.requestId}`)
    channel
    .join()
    .receive("ok", this.onChannelResponse.bind(this))
    .receive("error", resp => { console.log("Unable to join", resp) });

    channel.on("ready", this.onChannelResponse.bind(this));
  }

  onChannelResponse(response){
    if (response.html) {
      this.renderToolbar(response);
    } else {
      console.log(response);
    }
  }

  renderToolbar({html: html, request: request}){
    console.log("Request: ", request);
    const toolbar = $(`<div class="ex-debug-toolbar">${html}</div>`);
    toolbar.appendTo('body');
    this.renderPanels(toolbar);
    this.highlightCode(toolbar);
    this.renderPopovers();
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

  highlightCode(toolbar) {
    toolbar.find(".code").each((i, block) => {
      Highlight.highlightBlock(block)
    })
  }

  renderPopovers() {
    $('[data-toggle="popover"]').popover();
  }
}

(new App({requestId: window.requestId})).render();
