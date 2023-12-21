FROM alpine:latest as alpine-dev
RUN apk add --no-cache gcc musl-dev make git janet

WORKDIR /build
RUN git clone https://github.com/janet-lang/janet && \
    cd janet && \
    PREFIX=/usr make install && \
    PREFIX=/usr make install-jpm-git && \
    cd .. && \
    rm -rf janet && \
    jpm install spork

WORKDIR /app
COPY . .

ENTRYPOINT [ "janet" ]
CMD [ "/app/bin/echo.janet" ]
