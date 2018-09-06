FROM debian:latest
MAINTAINER mail@vanmarten.nl

SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get -y install build-essential libssl-dev curl git \
  && apt-get -y install make \
        zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libbluetooth-dev

ENV PYENV_ROOT /usr/share/pyenv

RUN git clone --single-branch -b v1.2.7 https://github.com/pyenv/pyenv.git $PYENV_ROOT \
    && git clone https://github.com/momo-lab/pyenv-install-latest.git $PYENV_ROOT/plugins/pyenv-install-latest \
    && echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' >> /root/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> /root/.bashrc

ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
RUN PYTHON36VERSION=$(pyenv install-latest --print 3.6) \
      && pyenv install $PYTHON36VERSION \
      && pyenv global $PYTHON36VERSION


VOLUME /conf
VOLUME /certs
EXPOSE 5050

# Environment vars we can configure against
# But these are optional, so we won't define them now
#ENV HA_URL http://hass:8123
#ENV HA_KEY secret_key
#ENV DASH_URL http://hass:5050
#ENV EXTRA_CMD -D DEBUG

# Copy appdaemon into image
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone --single-branch -b master https://github.com/home-assistant/appdaemon.git ./

# Install
RUN pip3 install .

## cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start script
RUN chmod +x /usr/src/app/dockerStart.sh
CMD [ "./dockerStart.sh" ]
