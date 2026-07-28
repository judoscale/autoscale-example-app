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

  get toggleLabel() {
    return this.polling ? "Stop polling" : "Start polling";
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
    this.intervalId = setInterval(() => this.poll(), 2000);
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

Alpine.data("requestInterceptor", () => ({
  pending: 0,
  timings: [],
  queueTimings: [],
  requestStarts: [],

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

  handleSubmit(event) {
    if (this.pending === 0) {
      this.timings = [];
      this.queueTimings = [];
      this.requestStarts = [];
    }

    this.pending += 1;

    const start = new Date();

    makeRequest(event.target, ({ queueTime, requestStart }) => {
      this.pending -= 1;
      this.timings.push(new Date() - start);
      this.queueTimings.push(queueTime);
      this.requestStarts.push(requestStart);
    });
  },
}));

Alpine.start();

function makeRequest(form, onComplete) {
  const formData = new FormData(form);
  const params = new URLSearchParams(formData).toString();
  const url = `${form.action}?${params}`;

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
