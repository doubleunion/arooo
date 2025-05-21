FROM ruby:3.4.3-slim

# Install essential packages, PostgreSQL client, and a JavaScript runtime
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libpq-dev \
        nodejs \
        npm \
        tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory in the container
WORKDIR /app

# Copy Gemfile and Gemfile.lock to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install Bundler. Use a version compatible with your Gemfile.lock (e.g., if BUNDLED WITH is 2.6.9, this covers it)
RUN gem install bundler -v '~> 2.4' --conservative --minimal-deps

# Configure Bundler to install gems to /usr/local/bundle (shared volume via docker-compose)
ENV BUNDLE_PATH /usr/local/bundle

# Install gems
RUN bundle install --jobs $(nproc) --retry 3

# Copy the rest of the application code into the container
COPY . .

# Expose the port Rails runs on
EXPOSE 3000

# Default command to start the application (can be overridden)
CMD ["bash"]
