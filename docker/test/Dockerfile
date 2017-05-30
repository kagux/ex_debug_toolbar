FROM elixir:1.4

MAINTAINER Juan Peri

ENV MIX_ENV test

RUN mix local.hex --force
RUN mix local.rebar --force

# Install sass
RUN apt-get install -y ruby && gem install sass

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install yarn

WORKDIR /app

ADD mix.exs mix.exs
ADD mix.lock mix.lock

RUN mix deps.get
RUN mix deps.compile

ADD . /app
RUN mix compile
