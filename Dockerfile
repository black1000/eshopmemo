
# Rails 8 互換の安定版Rubyを使用
ARG RUBY_VERSION=3.3.0 
FROM ruby:$RUBY_VERSION-slim AS development

# 必要なシステムパッケージのインストール (PostgreSQLクライアント、ビルドツールなど)
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを設定し、全てのコードをコピー
WORKDIR /rails
COPY Gemfile Gemfile.lock /rails/

# 開発用Gemを含めて全てインストール（BUNDLE_WITHOUTを設定しないため、developmentグループのGemも入る）
RUN bundle install

# アプリケーションのコードをコピー
COPY . /rails