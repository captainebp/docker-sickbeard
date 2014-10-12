FROM	ubuntu:14.04
MAINTAINER	Benoît Pourre "benoit.pourre@gmail.com"

RUN	locale-gen en_US en_US.UTF-8

# Make sure we don't get notifications we can't answer during building.
ENV	DEBIAN_FRONTEND noninteractive

# Update the system
RUN	apt-get -q update
RUN	apt-mark hold initscripts udev plymouth mountall
RUN	apt-get -qy --force-yes dist-upgrade

RUN	apt-get install -qy --force-yes python-cheetah git supervisor wget tar ca-certificates curl
RUN	cd /srv && git clone https://github.com/midgetspy/Sick-Beard.git sickbeard

#Volume for Sickbeard DB, logs, cache and configuration
VOLUME	/data
#Volume for media folders
VOLUME	/media

#Expose Sickebear port
EXPOSE	8081

# Configure a localshop user
# Prepare user
RUN addgroup --system downloads -gid 1001
RUN adduser --system --gecos downloads --shell /usr/sbin/nologin --uid 1001 --gid 1001 --disabled-password  downloads

# Clean up
RUN	apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/* && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup

ADD	./start /start
RUN	chmod u+x  /start
ADD	./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD	./supervisor/conf.d/sickbeard.conf /etc/supervisor/conf.d/sickbeard.conf

# Fix all permissions
RUN	chmod +x /start; chown -R downloads:downloads /srv/sickbeard /media /data

# Execute start.sh whatever CMD is given
ENTRYPOINT	["/start"]
