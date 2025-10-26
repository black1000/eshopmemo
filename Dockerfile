ARG RUBY_VERSION=3.3.6
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages for runtime
RUN apt-get update -qq && \
    apt-get install -y libpq-dev postgresql-client nodejs npm && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install build tools for native extensions
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

#  package.json / yarn.lock が存在する場合のみコピー
# TailwindCSS (tailwindcss-rails) は内部的にビルドで Node/Yarn を使うことがあるため保持
COPY package.json* yarn.lock* ./
RUN if [ -f package.json ]; then yarn install --frozen-lockfile; fi

# Copy application code
COPY . /rails

# Fix bin permissions for Linux
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# 重要: アセットプリコンパイル (production 環境で DB 接続不要)
ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummy_key_for_assets \
    DATABASE_NAME=dummy \
    DATABASE_USERNAME=dummy \
    DATABASE_PASSWORD=dummy \
    DATABASE_HOST=localhost \
    DATABASE_PORT=5432

# assets:precompile
RUN bundle exec rails assets:precompile

# Final runtime image
FROM base

# Copy built app and gems
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails /usr/local/bundle
USER 1000:1000

# Entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]