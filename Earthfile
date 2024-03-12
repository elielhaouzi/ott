VERSION 0.7

elixir-builder-base:
  FROM hexpm/elixir:1.15.7-erlang-26.1.2-alpine-3.17.5
  RUN apk add --no-progress --update build-base openssh-client git postgresql-client
  
  RUN rm -rf /var/lib/apt/lists/*
  RUN rm -rf /var/cache/apk/*

  RUN mix local.rebar --force && \
      mix local.hex --force

  WORKDIR /app

elixir-deps:
  ARG MIX_ENV
  FROM +elixir-builder-base
  ENV MIX_ENV="$MIX_ENV"
  COPY mix.exs mix.lock ./
  RUN mix deps.get --only "$MIX_ENV"
  RUN mix deps.compile

  SAVE ARTIFACT deps/* .

lint:
    FROM --build-arg MIX_ENV="dev" +elixir-deps
    COPY .formatter.exs .
    RUN mix deps.unlock --check-unused
    RUN mix format --check-formatted
    RUN mix compile --warnings-as-errors

test:
  FROM earthly/dind:alpine
  WORKDIR /test
  RUN apk add --no-progress --update postgresql-client
  
  COPY --dir config lib priv test .

  ARG PG_IMG="postgres:16.2"
  
  WITH DOCKER --pull "$PG_IMG" --load elixir:latest=+elixir-deps --build-arg MIX_ENV="test"
      RUN timeout=$(expr $(date +%s) + 60); \
        
        docker run --name pg --network=host -d -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=ott "$PG_IMG"; \

        while ! pg_isready --host=127.0.0.1 --port=5432 --quiet; do \
            test "$(date +%s)" -le "$timeout" || (echo "timed out waiting for postgres"; exit 1); \
            echo "waiting for postgres"; \
            sleep 1; \
        done; \

        docker run \
            --rm \
            -e DATABASE_URL="ecto://postgres:postgres@127.0.0.1:5432/ott" \
            -e MIX_ENV=test \
            -e EX_LOG_LEVEL=warning \
            --network host \
            -v "$PWD/config:/app/config" \
            -v "$PWD/lib:/app/lib" \
            -v "$PWD/priv:/app/priv" \
            -v "$PWD/test:/app/test" \
            -w /app \
            --name ott \
            elixir:latest mix test;
            # elixir:latest mix test --trace --slowest 10;
          #   elixir:latest mix test --trace --slowest 10 --cover;
  END


check-tag:
    FROM +elixir-builder-base

    COPY mix.exs .

    ARG TAG
    ARG APP_VERSION=$(mix app.version)

    IF [ ! -z $TAG ] && [ ! $TAG == $APP_VERSION ]
        RUN echo "TAG '$TAG' has to be equal to APP_VERSION '$APP_VERSION'" && false
    END