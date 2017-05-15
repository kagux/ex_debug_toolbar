FROM elixir:1.4

MAINTAINER Juan Peri

ENV MIX_ENV test

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /app

ADD mix.exs mix.exs
ADD mix.lock mix.lock

RUN mix deps.get
RUN mix deps.compile

ADD . /app
RUN mix compile
