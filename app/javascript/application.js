// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Alpine from "alpinejs";
window.Alpine = Alpine;

Alpine.data("requestHandler", () => ({
  pending: 0,
  timings: [],

  get completedCount() {
    return this.timings.length;
  },

  get avgTiming() {
    if (this.timings.length === 0) return "";

    const sum = this.timings.reduce((acc, t) => acc + t, 0);
    return `${Math.round(sum / this.timings.length)}ms`;
  },

  form: {
    ["@submit"](e) {
      e.preventDefault();

      // Clear the timings if this is the first in a series of requests
      if (this.pending === 0) this.timings = [];

      this.pending += 1;
      let time = new Date();

      makeRequest(e.target, () => {
        this.pending -= 1;
        this.timings.push(new Date() - time);
      });
    },
  },
}));

Alpine.start();

function makeRequest(form, onComplete) {
  let formData = new FormData(form);
  let params = new URLSearchParams(formData).toString();

  fetch(`${form.action}?${params}`).then(onComplete);
}
