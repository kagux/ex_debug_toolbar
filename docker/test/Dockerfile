FROM elixir:1.4

MAINTAINER Juan Peri

ENV MIX_ENV test

RUN groupadd dev && useradd -m -g dev dev

WORKDIR /app

ADD . /app

RUN chown -R dev:dev /app

USER dev

RUN mix local.hex --force \
&& mix local.rebar --force \
&& mix do deps.get, deps.compile, compile
