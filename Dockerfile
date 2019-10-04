FROM ubuntu:19.10
LABEL maintainer smysore@servicefractal.com

## Install packages
RUN apt-get -q update && apt-get -y -q upgrade && apt-get -y -q --no-install-recommends install apt-utils ca-certificates \
    && apt-get --assume-yes -q --no-install-recommends install \
                    apt-transport-https \
                    software-properties-common \
                    iproute2 \
                    isc-dhcp-client \
                    python3 \
                    openvswitch-common \
                    openvswitch-switch \
                    openvswitch-switch-dpdk \
                    python3-openvswitch \
                    openvswitch-pki \
                    openvswitch-testcontroller \
    && apt-get -q -y autoremove \
    && apt-get -q clean

# Create database and pid file directory
ADD create_ovs_db.sh /etc/openvswitch/create_ovs_db.sh
RUN /etc/openvswitch/create_ovs_db.sh

ADD ovs-override.conf /etc/depmod.d/openvswitch.conf

ADD start-ovs /bin/start-ovs

VOLUME ["/var/log/openvswitch", "/var/lib/openvswitch", "/var/run/openvswitch", "/etc/openvswitch"]

ENTRYPOINT ["start-ovs"]
