FROM ubuntu:latest
LABEL authors="dastan"

ENTRYPOINT ["top", "-b"]