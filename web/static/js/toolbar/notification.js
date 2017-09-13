import $ from './jquery';

class Notification {
  static send(type, msg) {
    $.notify({
      icon: '/__ex_debug_toolbar__/images/logo.svg',
      message: msg,
    }, {
      icon_type: 'img',
      placement: {
        from: "bottom",
        align: "center"
      },
      delay: 300,
      timer: 100,
      offset: {
        y: 35
      },
      type: type,
      template: `
        <div id="edt-notification" data-notify="container" class="col-xs-11 col-sm-3 alert alert-{0}" role="alert">
          <button type="button" aria-hidden="true" class="close" data-notify="dismiss">×</button>
          <span data-notify="icon"></span>
          <span data-notify="title">{1}</span>
          <span data-notify="message">{2}</span>
      </div>
      `
    });
  }
}

export default Notification;
