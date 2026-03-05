# syntax=docker/dockerfile:1

# Build stage
FROM hexpm/elixir:1.16.5-erlang-28.1-alpine-3.20 as builder

RUN apk add --no-cache build-base npm git python3

WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install Elixir dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy rest of the code
COPY . .

# Build assets
RUN npm ci --prefix assets && \
    mix assets.deploy

# Build release
RUN mix release

# Runtime stage
FROM alpine:3.20

RUN apk add --no-cache libncurses dumb-init ca-certificates openssl

WORKDIR /app

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/elixir4vet ./

# Create app user
RUN addgroup -g 1001 -S app && \
    adduser -u 1001 -S app -G app && \
    chown -R app:app /app

USER app

ENV HOME=/app

EXPOSE 4000

ENTRYPOINT ["/sbin/dumb-init", "--"]

CMD ["bin/elixir4vet", "start"]
