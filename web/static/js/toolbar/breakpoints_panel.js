import $ from '../lib/jquery';
import {default as Term} from 'xterm';
require('xterm/lib/addons/fit/fit');
require('xterm/lib/addons/fullscreen/fullscreen');

class BreakpointsPanel {
  constructor(socket, toolbar) {
    this.socket = socket;
    this.toolbar = toolbar;
  }

  render(request_id) {
    this.request_id = request_id
    this.appendModalToBody();
    this.renderModal();
    this.renderCodeSnippets();
  }

  appendModalToBody() {
    $('#breakpoints-modal', this.toolbar).detach().appendTo(this.toolbar);
  }

  renderModal() {
    $('#breakpoints-modal', this.toolbar)
    .on('shown.bs.modal', this.renderTerm.bind(this))
    .on('hidden.bs.modal', this.destroyTerm.bind(this))
    $('.breakpoint', this.toolbar).click(this.showModal.bind(this));
    $('[data-toggle="fullscreen"]', this.toolbar).click(this.toggleFullscreen.bind(this));
    this.renderBindingPopover();
    $(window).resize(this.resizeTerm.bind(this));
  }

  renderCodeSnippets() {
    this.toolbar.find('.breakpoint').each((i, el) => {
      const $el = $(el);
      $el.hover(() => {
        const html = $el.find('.code-snippet').html();
        $('#code-snippet-container').html(html);
      })
    })
  }

  renderBindingPopover() {
    $('[data-toggle="binding"]', this.toolbar).popover({
      container: 'body',
      content: () => $('*[data-breakpoint-id="' + this.breakpoint_id +'"] .binding-popover', this.toolbar).html(),
        html: true,
      trigger: 'hover',
      title: 'Binding'
    });
  }

  showModal({target: target}) {
    this.breakpoint_id = $(target).closest('tr').data('breakpoint-id');
    $('#breakpoints-modal', this.toolbar).modal();
  }

  toggleFullscreen() {
    this.term.toggleFullscreen();
    $('#breakpoints-modal', this.toolbar).toggleClass('fullscreen');
    this.term.focus();
    this.resizeTerm();
  }

  resizeTerm() {
    if (! this.term) {
      return;
    }

    const termEl = $('#breakpoints-modal .terminal.xterm.fullscreen', this.toolbar);
    const parentEl = $('#terminal-container', this.toolbar);
    if (termEl[0]) {
      parentEl.height(termEl.height());
      parentEl.width(termEl.width());
    } else {
      parentEl.height("");
      parentEl.width("");
    }
    this.term.fit();
  }

  destroyTerm() {
    this.channel.leave();
    this.term.destroy();
    $('#breakpoints-modal', this.toolbar).removeClass('fullscreen');
  }

  renderTerm() {
    this.channel = this.joinBreakpointChannel(this.socket);
    this.term = new Term({
      cursorBlink: true
    });
    this.term.open(document.getElementById('terminal-container'), true);
    this.term.on('data', (data) => this.channel.push('input', {input: data}));
    this.resizeTerm();
  }

  joinBreakpointChannel(socket) {
    const channel = socket.channel("breakpoint:" + this.breakpoint_id);
    channel.join();
    channel.on('output', ({output}) => this.term.write(output));

    return channel;
  }
}

export default BreakpointsPanel;
