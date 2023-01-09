FROM dart:2.18.6-sdk

RUN apt-get update && apt-get install -y \
  protobuf-compiler \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN groupadd --system dart && \
  useradd --no-log-init --system --home /home/dart --create-home -g dart dart
RUN chown dart:dart /app

# Work around https://github.com/dart-lang/sdk/issues/47093
RUN find /usr/lib/dart -type d -exec chmod 755 {} \;

USER dart

RUN dart pub global activate protoc_plugin

COPY --chown=dart:dart pubspec.* /app/
COPY --chown=dart:dart third_party /app/third_party
RUN ls -al
RUN dart pub get
COPY --chown=dart:dart . /app
RUN dart pub get --offline

ARG SERVER_URL
RUN export PATH=$PATH:$HOME/.pub-cache/bin && \
  dart tool/grind.dart build \
    "--server-url=$SERVER_URL"

CMD ["dart", "bin/serve.dart"]
