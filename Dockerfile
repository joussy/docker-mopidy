FROM debian:buster

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        dumb-init \
        gcc \
        gnupg \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python3 \
        python3-pip \
        python3-gst-1.0 \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-tools \
        gstreamer1.0-pulseaudio

RUN pip3 --no-cache-dir install Mopidy

RUN pip3 --no-cache-dir install Mopidy-MusicBox-Webclient

RUN pip3 --no-cache-dir install Mopidy-Youtube==3.0

RUN mkdir -p /var/lib/mopidy/.config && ln -s /config /var/lib/mopidy/.config/mopidy

# RUN apt-get purge --auto-remove -y \
#         curl \
#         gcc \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY mopidy.conf /config/mopidy.conf

# Copy the pulse-client configuratrion.
COPY pulse-client.conf /etc/pulse/client.conf

# Allows any user to run mopidy, but runs by default as a randomly generated UID/GID.
ENV HOME=/var/lib/mopidy
# RUN set -ex \
#  && usermod -G audio,sudo mopidy \
#  && chown mopidy:audio -R $HOME /entrypoint.sh \
#  && chmod go+rwx -R $HOME /entrypoint.sh

# # Runs as mopidy user by default.
# USER mopidy

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
CMD ["/usr/local/bin/mopidy"]
