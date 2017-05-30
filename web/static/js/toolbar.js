import "phoenix_html"
import {Socket} from "phoenix"

class App {
  constructor(opts) {
    this.opts = opts;
  }

  render() {
    let socket = new Socket("/__ex_debug_toolbar__/socket");
    socket.connect();
    let request_channel = socket.channel("toolbar:request:" + this.opts.requestId, {});
    request_channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
    let all_requests_channel = socket.channel("toolbar:requests", {});
    all_requests_channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
  }
}

(new App({requestId: window.requestId})).render();
