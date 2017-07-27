import 'phoenix_html';
import {Socket} from 'phoenix';
import $ from 'jquery';
import BreakpointsPanel from './toolbar/breakpoints_panel.js';
import Prism from 'prismjs';
import 'prismjs/components/prism-elixir';
import 'prismjs/components/prism-sql';
import 'prismjs/plugins/normalize-whitespace/prism-normalize-whitespace';
import 'prismjs/plugins/line-numbers/prism-line-numbers';
import 'prismjs/plugins/line-highlight/prism-line-highlight';

window.jQuery = $;
require('bootstrap-sass');

class App {
  constructor(opts) {
    this.opts = opts;
    this.resetActivePanel();
  }

  render() {
    const socket = this.initSocket();
    this.joinToolbarChannel(socket);
    this.breakpointsPanel = new BreakpointsPanel(socket);
  }

  initSocket() {
    const socket = new Socket("/__ex_debug_toolbar__/socket");
    socket.connect();
    return socket;
  }

  joinToolbarChannel(socket) {
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
    const toolbar = $(`<div id="ex-debug-toolbar"><div>${html}</div></div>`);
    toolbar.appendTo('body');
    this.renderPanels(toolbar);
    this.renderPopovers(toolbar);
    this.breakpointsPanel.render();
    this.highlightCode(toolbar);
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
    Prism.plugins.NormalizeWhitespace.setDefaults({
      'remove-trailing': true,
      'remove-indent': true,
      'left-trim': true,
      'right-trim': true,
      'remove-initial-line-feed': true,
    });
    toolbar.find(".code").each((i, el) => {
      Prism.highlightElement(el, false)
    })
  }

  renderPopovers(toolbar) {
    $(toolbar).find('[data-toggle="popover"]').popover();
  }
}

(new App({requestId: window.requestId})).render();
