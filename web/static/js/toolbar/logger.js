class Logger {
  constructor(enabled) {
    this.enabled = enabled;
  }

  debug(...args) {
    this.enabled && console.log('[ExDebugToolbar]', ...args)
  }
}

export default Logger;
