FROM swift:5.1.1
COPY . /app
WORKDIR /app
RUN swift package resolve
ENTRYPOINT ["swift", "test"]
