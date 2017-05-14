FROM elixir:1.4

MAINTAINER Juan Peri

ENV MIX_ENV test

RUN mix local.hex --force
RUN mix local.rebar --force

ADD . /app
WORKDIR /app

RUN mix deps.get
RUN mix deps.compile
RUN mix compile
