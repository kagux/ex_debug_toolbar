import $ from 'jquery';
import {default as Term} from 'xterm';
require('xterm/lib/addons/fit/fit');
require('xterm/lib/addons/fullscreen/fullscreen');

class BreakpointsPanel {
  constructor(socket) {
    this.socket = socket;
  }

  render() {
    this.appendModalToBody();
    this.renderModal();
    this.renderCodeSnippets();
  }

  appendModalToBody() {
    $('#breakpoints-modal').detach().appendTo('#ex-debug-toolbar');
  }

  renderModal() {
    $('#breakpoints-modal')
    .on('shown.bs.modal', this.renderTerm.bind(this))
    .on('hidden.bs.modal', this.destroyTerm.bind(this))
    $('.breakpoint').click(this.showModal.bind(this));
    $('[data-toggle="fullscreen"]').click(this.toggleFullscreen.bind(this));
    this.renderBindingPopover();
    $(window).resize(this.resizeTerm.bind(this));
  }

  renderCodeSnippets() {
    $('#ex-debug-toolbar .breakpoint').each((i, el) => {
      const $el = $(el);
      $el.hover(() => {
        const html = $el.find('.code-snippet').html();
        $('#code-snippet-container').html(html);
      })
    })
  }

  renderBindingPopover() {
    $('[data-toggle="binding"]').popover({
      container: 'body',
      content: () => $('#'+this.breakpoint_id + ' .binding-popover').html(),
        html: true,
      trigger: 'hover',
      title: 'Binding'
    });
  }

  showModal({target: target}) {
    this.breakpoint_id = $(target).closest('tr').attr('id');
    $('#breakpoints-modal').modal();
  }

  toggleFullscreen() {
    this.term.toggleFullscreen();
    $('#breakpoints-modal').toggleClass('fullscreen');
    this.term.focus();
    this.resizeTerm();
  }

  resizeTerm() {
    if (! this.term) {
      return;
    }

    const termEl = $('#breakpoints-modal .terminal.xterm.fullscreen');
    const parentEl = $('#terminal-container');
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
    $('#breakpoints-modal').removeClass('fullscreen');
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
    const topic = "breakpoint:" + this.breakpoint_id;
    const channel = socket.channel(topic, {});
    channel.join();
    channel.on('output', ({output}) => this.term.write(output));

    return channel;
  }
}

export default BreakpointsPanel;
