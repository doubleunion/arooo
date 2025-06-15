# Use an official Ruby image as a parent image
FROM ruby:3.2.8-bullseye

# Set environment variables
ENV LANG C.UTF-8
ENV RAILS_ENV development
ENV RACK_ENV development
ENV PORT 3000

# Install system dependencies
# - build-essential: For compiling native extensions
# - libpq-dev: For the pg gem (PostgreSQL client library)
# - nodejs, yarn: For JavaScript runtime and package management (if needed by Rails asset pipeline)
# - postgresql-client: For psql command-line utility
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Add user to sudoers with no password (optional, for convenience)
    && apt-get update && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /workspace

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems for the non-root user to avoid permission issues with host mounts
# Ensure bundle path is writable by the user
USER $USERNAME
RUN mkdir -p /home/$USERNAME/.bundle \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.bundle \
    && bundle install --jobs $(nproc) --retry 3

# Copy the rest of the application code
USER root
COPY . .
RUN chown -R $USERNAME:$USERNAME /workspace

# Switch back to non-root user
USER $USERNAME

# Expose port 3000 and set the default command
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
