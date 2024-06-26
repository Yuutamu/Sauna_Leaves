# ベースイメージと基本設定
FROM ruby:3.3.0-slim-bookworm AS assets
# LABEL maintainer="Nick Janetakis <nick.janetakis@gmail.com>"

WORKDIR /app

ARG UID=1000
ARG GID=1000

# TODO: ハードコードしているので、後ほどセキュアにする
# 
ENV RAILS_MASTER_KEY=548b47f49851280a19e31c5f169b688a
ENV SECRET_KEY_BASE=b14a3039f17d4cdbcc90e408b1a3835357871e8a7c835bd7a09ad00a6be16f2ca06ebd664f8287276d94f9c8456fcf0e7bec7521b63a2ca7a709cdf99e28f94b

RUN bash -c "set -o pipefail && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl git libpq-dev \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /etc/apt/keyrings/nodesource.asc \
  && echo 'deb [signed-by=/etc/apt/keyrings/nodesource.asc] https://deb.nodesource.com/node_20.x nodistro main' | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y --no-install-recommends nodejs \
  && corepack enable \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g \"${GID}\" ruby \
  && useradd --create-home --no-log-init -u \"${UID}\" -g \"${GID}\" ruby \
  && mkdir /node_modules && chown ruby:ruby -R /node_modules /app"

USER ruby

# 依存パッケージのインストール
COPY --chown=ruby:ruby Gemfile* ./
RUN bundle install

COPY --chown=ruby:ruby package.json *yarn* ./
RUN yarn install

# アセットのプリコンパイルを実行
ARG RAILS_ENV="production"
ARG NODE_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/home/ruby/.local/bin:/node_modules/.bin" \
    USER="ruby"

COPY --chown=ruby:ruby . .

# RUN if [ "${RAILS_ENV}" != "development" ]; then \
#   SECRET_KEY_BASE_DUMMY=1 rails assets:precompile; fi

# プリコンパイルの実行
RUN RAILS_MASTER_KEY=$RAILS_MASTER_KEY rails assets:precompile
RUN SECRET_KEY_BASE=$SECRET_KEY_BASE rails assets:precompile

CMD ["bash"]

###############################################################################

FROM ruby:3.3.0-slim-bookworm AS app
# LABEL maintainer="Nick Janetakis <nick.janetakis@gmail.com>"

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl libpq-dev vim \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g "${GID}" ruby \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" ruby \
  && chown ruby:ruby -R /app

USER ruby

COPY --chown=ruby:ruby bin/ ./bin
RUN chmod 0755 bin/*

ARG RAILS_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="ruby"

COPY --chown=ruby:ruby --from=assets /usr/local/bundle /usr/local/bundle
COPY --chown=ruby:ruby --from=assets /app/public /public
COPY --chown=ruby:ruby . .

ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 8000

CMD ["rails", "s"]
