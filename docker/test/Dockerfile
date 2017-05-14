FROM elixir:1.4

MAINTAINER Juan Peri

ENV MIX_ENV test

ADD . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get
RUN mix deps.compile
