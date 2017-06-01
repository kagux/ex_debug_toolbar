import 'phoenix_html';
import {Socket} from 'phoenix';
import $ from "jquery";
import Highlight from "highlight.js";
window.jQuery = $;
require('bootstrap-sass');

class App {
  constructor(opts) {
    this.opts = opts;
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
    this.renderPopovers(toolbar);
    this.highlightCode(toolbar);
  }

  renderPopovers(toolbar) {
    toolbar.find('[data-toggle="popover"]').each((i, el) => {
      $(el).popover({
        container: el,
        placement: 'top',
        trigger: 'hover',
        html: true,
        content: function() {
          return $(this).parent().find('[data-role="popover-content"]').html();
        }
      });
    });
  }

  highlightCode(toolbar) {
    toolbar.find(".code").each((i, block) => {
      Highlight.highlightBlock(block)
    })
  }
}

(new App({requestId: window.requestId})).render();
