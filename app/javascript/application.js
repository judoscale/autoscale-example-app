// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Alpine from "alpinejs";

window.Alpine = Alpine;

Alpine.data("requestInterceptor", () => ({
  pending: 0,
  timings: [],

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

  form: {
    ["@submit"](event) {
      if (this.pending === 0) this.timings = [];

      this.pending += 1;
      event.preventDefault();

      const start = new Date();

      makeRequest(event.target, () => {
        this.pending -= 1;
        this.timings.push(new Date() - start);
      });
    },
  },
}));

Alpine.start();

function makeRequest(form, onComplete) {
  const formData = new FormData(form);
  const params = new URLSearchParams(formData).toString();
  const url = `${form.action}?${params}`;

  fetch(url).then(onComplete);
}
