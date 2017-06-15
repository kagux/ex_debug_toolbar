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
    socket
    .channel("toolbar:request", {id: this.opts.requestId})
    .join()
    .receive("ok", this.renderToolbar.bind(this))
    .receive("error", resp => { console.log("Unable to join", resp) })
  }

  renderToolbar({html: html, request: request}){
    console.log("Request: ", request);
    const toolbar = $(`<div class="ex-debug-toolbar">${html}</div>`);
    toolbar.appendTo('body');
    this.renderPanels(toolbar);
    this.highlightCode(toolbar);
  }

  renderPanels(toolbar) {
    toolbar
    .mouseleave(this.hideActivePanel.bind(this))
    .find('[data-toggle="panel"]')
    .hover(this.showPanel.bind(this));
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
}

(new App({requestId: window.requestId})).render();
