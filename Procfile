web: bundle exec rails server

# Default to 1 worker thread unless specified in WORKER_THREADS env var
worker: "RAILS_MAX_THREADS=${WORKER_THREADS:-1} bundle exec sidekiq -q urgent -q default"
