# Running [Open vSwitch (OVS)](http://www.openvswitch.org/) on Containers

[![](https://images.microbadger.com/badges/version/shivarammysore/ovs.svg)](https://microbadger.com/images/shivarammysore/ovs "Version")
[![](https://images.microbadger.com/badges/image/shivarammysore/ovs.svg)](https://microbadger.com/images/shivarammysore/ovs "Image Layers")

## Introduction

Traditionally, we have OVS running as a part of Operating System (Unbutu, Fedora) installed primarily as a package.  This project is an effort to run OVS inside of a container.  We use [Docker](https://docker.com) as a the default container platform and [Fedora CoreOS](https://getfedora.org/coreos/) as as the underlying OS.

## Prerequisities

  *  Fedora CoreOS with user `core` and `$HOME` directory under `/home/core`
  *  Fedora CoreOS is installed on x86 bare metal with 4 ethernet ports (`eth0` - `eth3`)
  *  `eth0` is used as management port.  Rest of the ports are used as ports on OVS bridge
  *  [Faucet](https://faucet.nz) Openflow based Controller is used to test Openflow mode on OVS.
  *  `openvswitch, vport_geneve, vport_gre, vport_vxlan, tap` Kernel modules are autoloaded on boot

## Usage

### OVS on Containers Deployment Architecture

![OVS on Containers Deployment Archiecture](https://github.com/shivarammysore/ovs/raw/master/docs/images/OVSonContainers.png)

A [SVG version](https://github.com/shivarammysore/ovs/raw/master/docs/images/OVSonContainers.svg) of the image

### Steps

```shell
  $ cd $HOME 
  $ sudo install -d --owner=root --group=root --mode=0755 \
    /home/core/ovs/log \
    /home/core/ovs/var/lib/openvswitch/pki \
    /home/core/ovs/var/run/openvswitch \
    /home/core/ovs/etc/openvswitch
  $ docker pull servicefractal/ovs:latest
  $ docker run \
    --name=ovsdb-server \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --cap-add=SYS_NICE \
    --network=host \
    --volume=/lib/modules:/lib/modules \
    --volume=/home/core/ovs/log:/var/log/openvswitch \
    --volume=/home/core/ovs/var/lib/openvswitch:/var/lib/openvswitch \
    --volume=/home/core/ovs/var/run/openvswitch:/var/run/openvswitch \
    --volume=/home/core/ovs/etc/openvswitch:/etc/openvswitch \
    --security-opt label=disable \
    --privileged \
    servicefractal/ovs:latest ovsdb-server
  $ docker run \
    --name=ovs-vswitchd \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --cap-add=SYS_NICE \
    --network=host \
    --volumes-from=ovsdb-server \
    --security-opt label:disable \
    --privileged \
    servicefractal/ovs:latest ovs-vswitchd
  $ docker exec -it ovs-vswitchd ovs-vsctl show
  $ docker exec -it ovs-vswitchd ovs-vsctl --may-exist add-br ovs-br0 \
    -- set bridge ovs-br0 protocols=OpenFlow13 \
    other_config:datapath-id=0x08090A0B0C0D0E0F \
    other_config:dp-desc=baremetal-ovs
  $ docker exec -it ovs-vswitchd ovs-vsctl set-fail-mode ovs-br0 secure
  $ docker exec -it ovs-vswitchd ovs-vsctl get bridge ovs-br0 datapath_id
  $ docker exec -it ovs-vswitchd ovs-vsctl add-port ovs-br0 eth1 -- set Interface eth1 ofport_request=1 type=system
  $ docker exec -it ovs-vswitchd ovs-vsctl add-port ovs-br0 eth2 -- set Interface eth2 ofport_request=2 type=system
  $ docker exec -it ovs-vswitchd ovs-vsctl add-port ovs-br0 eth3 -- set Interface eth3 ofport_request=3 type=system
  $ docker exec -it ovs-vswitchd ovs-vsctl set-controller ovs-br0 tcp:openflow_controller.example.org:6653
  $ docker exec -it ovs-vswitchd ovs-vsctl show
```

The above set of commands will install the pre-built docker image for OVS, start it, create bridge, add system ports and finally configure the controller.


## Troubleshooting

Below are some useful commands to help with debugging.  This is not an exahaustive list, but just a quick reference.

```shell
  $ docker logs <container_name>
  $ sudo tail -f /home/core/ovs/log/ovs-vswitchd.log 
  $ ip a --> if ports are connected to OVS bridge, they will have ovs-system for the corresponding port
  $ sudo ls -C1 /lib/modules/$(uname -r)/kernel/net/openvswitch  --> check OVS Kernel modules 
  $ sudo modinfo openvswitch  --> Get Open vSwitch Kernel Module info 
  $ sudo /sbin/modprobe openvswitch  --> Load kernel module openvswitch
  $ sudo /sbin/lsmod | grep openvswitch  --> check if openvswitch kernel module is loaded
```

## Find Us

  *  [Sources on GitHub](https://github.com/servicefractal/ovs)
  *  [Docker Images](https://hub.docker.com/r/shivarammysore/ovs) or `docker pull shivarammysore/ovs`
  *  [Issues, feature requests, suggestions](https://github.com/servicefractal/ovs/issues)
  *  Twitter: [@servicefractal](https://twitter.com/servicefractal)
  *  Pull Requests, bug fixes, etc welcome
