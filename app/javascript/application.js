// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Alpine from "alpinejs";

window.Alpine = Alpine;

Alpine.data("queuePoller", (url, initialQueues) => ({
  polling: true,
  queues: initialQueues,
  intervalId: null,

  init() {
    this.startPolling();
  },

  destroy() {
    this.clearTimer();
  },

  toggle() {
    if (this.polling) {
      this.stopPolling();
    } else {
      this.startPolling({ immediate: true });
    }
  },

  startPolling({ immediate = false } = {}) {
    this.polling = true;
    this.clearTimer();
    if (immediate) this.poll();
    this.intervalId = setInterval(() => this.poll(), 1000);
  },

  stopPolling() {
    this.polling = false;
    this.clearTimer();
  },

  clearTimer() {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  },

  poll() {
    fetch(url, { headers: { Accept: "application/json" } })
      .then((response) => response.json())
      .then((queues) => {
        this.queues = queues;
      });
  },
}));

Alpine.data("requestInterceptor", (initialLatency, initialSleepPercent, initialRps) => ({
  sending: false,
  sent: 0,
  pending: 0,
  timings: [],
  queueTimings: [],
  requestStarts: [],
  form: null,
  timeoutId: null,
  runId: 0,
  latency: initialLatency,
  sleepPercent: initialSleepPercent,
  rps: initialRps,

  destroy() {
    this.clearTimer();
  },

  get completed() {
    return this.timings.length;
  },

  get lastResponseTime() {
    if (this.timings.length === 0) return "";

    return `${this.timings[this.timings.length - 1]}ms`;
  },

  get avgResponseTime() {
    if (this.timings.length === 0) return "";

    const sum = this.timings.reduce((acc, t) => acc + t, 0);
    return `${Math.round(sum / this.timings.length)}ms`;
  },

  formatUnavailable(value, suffix = "") {
    return value === null ? "unavailable" : `${value}${suffix}`;
  },

  formatQueueTime(value) {
    return this.formatUnavailable(value, "ms");
  },

  get lastQueueTime() {
    if (this.queueTimings.length === 0) return "";

    return this.formatQueueTime(
      this.queueTimings[this.queueTimings.length - 1],
    );
  },

  get avgQueueTime() {
    if (this.queueTimings.length === 0) return "";

    const available = this.queueTimings.filter((t) => t !== null);
    if (available.length === 0) return "unavailable";

    const sum = available.reduce((acc, t) => acc + t, 0);
    return `${Math.round(sum / available.length)}ms`;
  },

  get lastRequestStartTitle() {
    if (this.requestStarts.length === 0) return "";

    const value = this.requestStarts[this.requestStarts.length - 1];
    if (value === null) return "X-Request-Start: unavailable";

    return `X-Request-Start: ${value}`;
  },

  get loadTestUrl() {
    const url = new URL("/", window.location.origin);
    url.searchParams.set("latency", String(this.latency));
    url.searchParams.set("sleep_percent", String(this.sleepPercent));
    return url.toString();
  },

  get curlCommand() {
    return `curl '${this.loadTestUrl}'`;
  },

  get vegetaCommand() {
    return [
      `echo 'GET ${this.loadTestUrl}' \\`,
      `  | vegeta attack -rate=${this.rps} -duration=30s \\`,
      `  | vegeta report`,
    ].join("\n");
  },

  get vegetaForeverCommand() {
    return [
      `echo 'GET ${this.loadTestUrl}' \\`,
      `  | vegeta attack -rate=${this.rps} -duration=0 > results.bin`,
      `# Ctrl+C when done, then:`,
      `vegeta report results.bin`,
    ].join("\n");
  },

  handleSubmit(event) {
    if (this.sending) {
      this.stopSending();
      return;
    }

    this.startSending(event.target);
  },

  onOptionsChange(event) {
    this.syncOptionsFromForm(event.target.form);

    if (!this.sending) return;
    if (event.target.name !== "request_manager[rps]") return;

    this.scheduleNext();
  },

  syncOptionsFromForm(form) {
    if (!form) return;

    const data = new FormData(form);
    const latency = data.get("request_manager[latency]");
    const sleepPercent = data.get("request_manager[sleep_percent]");
    const rps = data.get("request_manager[rps]");

    if (latency != null && latency !== "") {
      this.latency = Number(latency);
    }
    if (sleepPercent != null && sleepPercent !== "") {
      this.sleepPercent = Number(sleepPercent);
    }
    if (rps != null && rps !== "") {
      this.rps = Number(rps);
    }
  },

  startSending(form) {
    this.runId += 1;
    this.sending = true;
    this.form = form;
    this.sent = 0;
    this.pending = 0;
    this.timings = [];
    this.queueTimings = [];
    this.requestStarts = [];
    this.syncOptionsFromForm(form);

    this.sendOne();
    this.scheduleNext();
  },

  stopSending() {
    this.sending = false;
    this.clearTimer();
  },

  scheduleNext() {
    this.clearTimer();
    if (!this.sending || !this.form) return;

    const rps = Number(new FormData(this.form).get("request_manager[rps]")) || 1;
    this.timeoutId = setTimeout(() => {
      this.sendOne();
      this.scheduleNext();
    }, 1000 / rps);
  },

  clearTimer() {
    if (this.timeoutId !== null) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  },

  sendOne() {
    const runId = this.runId;
    this.sent += 1;
    this.pending += 1;

    const start = new Date();

    makeRequest(this.form, ({ queueTime, requestStart }) => {
      if (runId !== this.runId) return;

      this.pending -= 1;
      this.timings.push(new Date() - start);
      this.queueTimings.push(queueTime);
      this.requestStarts.push(requestStart);
    });
  },
}));

Alpine.start();

function makeRequest(form, onComplete) {
  const url = new URL(form.action);
  // The page URL can already carry the curl query (latency, sleep_percent).
  // A GET form replaces that query; appending another "?" swallows
  // request_manager[latency] into the previous value.
  url.search = new URLSearchParams(new FormData(form)).toString();

  fetch(url).then((response) => {
    const queueHeader = response.headers.get("X-Queue-Time");
    const queueTime =
      queueHeader === null || queueHeader === ""
        ? null
        : Number.parseInt(queueHeader, 10);

    const requestStartHeader = response.headers.get("X-Request-Start");
    const requestStart =
      requestStartHeader === null || requestStartHeader === ""
        ? null
        : requestStartHeader;

    onComplete({
      queueTime: Number.isNaN(queueTime) ? null : queueTime,
      requestStart,
    });
  });
}
