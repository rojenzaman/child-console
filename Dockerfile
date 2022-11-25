FROM debian:latest

# set locales
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# install dependencies 
# do not use: ffmpeg
RUN apt-get update && apt-get install -y \
	tini git adduser wget make pv cowsay toilet sl curl lolcat \
	&& rm -rf /var/lib/apt/lists/*
ARG TARGETARCH
RUN wget -O /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${TARGETARCH} \
	&& chmod +x /usr/bin/ttyd

# create ttyd user and give sudo
RUN adduser --home /var/lib/ttyd ttyd --disabled-password --gecos ""

# switch to ttyd user and install
USER ttyd
WORKDIR /var/lib/ttyd
RUN git clone https://github.com/rojenzaman/child-console \
	&& sed -i '/make check/d' /var/lib/ttyd/child-console/console.sh

# local requirements
ENV PATH="${PATH}:/usr/games"
WORKDIR /var/lib/ttyd/child-console
EXPOSE 7681

# set ENTRYPOINT
# starting the application with tini
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["ttyd", "bash", "-c", "/var/lib/ttyd/child-console/console.sh"]
