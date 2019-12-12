FROM elixir:1.9
MAINTAINER libsys@gmail.com
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y inotify-tools build-essential postgresql-client && \
    mix local.rebar --force && \
    mix local.hex --force
# Uncomment if you need to use a front-end
RUN apt-get install -y sudo wget curl zip unzip
# If you plan to run a web interface, you'll want to use the following:
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - && apt-get install -y nodejs


COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV HOME=/app
ADD . $HOME
WORKDIR $HOME