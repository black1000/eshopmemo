ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages for runtime
RUN apt-get update -qq && \
    apt-get install -y libpq-dev nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    # 開発用Gemは不要なので除外
    BUNDLE_WITHOUT="development test"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems (e.g., pg gem)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . /rails

# Adjust binfiles to be executable on Linux
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# ★重要★ アセットのプリコンパイル
# SECRET_KEY_BASEがないとエラーになるため、ダミー値で実行
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image (runtime)
FROM base

# Copy built artifacts: gems, application, precompiled assets
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create non-root user for security (if your base image needs it)
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle
USER 1000:1000

# Entrypoint prepares the database and runs the server
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Rails server
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]