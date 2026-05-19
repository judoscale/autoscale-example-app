// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Alpine from "alpinejs";

window.Alpine = Alpine;

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

  get lastRequestStart() {
    if (this.requestStarts.length === 0) return "";

    return this.formatUnavailable(
      this.requestStarts[this.requestStarts.length - 1],
    );
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
