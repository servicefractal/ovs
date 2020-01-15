:Authors:
    Shivaram Mysore

Docker Networking Refresher Tutorial
====================================

Docker Host Networking
----------------------

The host driver
---------------

  *  Container is started with :code:`docker run --net host ...`
  *  It sees (and can access) the network interfaces of the host.
  *  It can bind any address, any port (for ill and for good).
  *  Network traffic doesn't have to go through ``NAT``, ``bridge``, or ``veth``.
  *  Performance = native!
  *  Reference: https://container.training/intro-selfpaced.yml.html#329

MACVLAN Docker network
----------------------

When using macvlan, you cannot ``ping`` or communicate with the default namespace IP address. For example, if you create a container and try to ping the Docker host’s ``eth0``, it will not work. That traffic is explicitly filtered by the kernel modules themselves to offer additional provider isolation and security.

A macvlan subinterface can be added to the Docker host, to allow traffic between the Docker host and containers. The IP address needs to be set on this subinterface and removed from the parent address.

The container driver
--------------------

  *  Container is started with :code:`docker run --net container:id ...`
  *  It re-uses the network stack of another container.
  *  It shares with this other container the same interfaces, IP address(es), routes, iptables rules, etc.
  *  Those containers can communicate over their lo interface.  (i.e. one can bind to ``127.0.0.1`` and the others can connect to it.)
  *  Reference: https://container.training/intro-selfpaced.yml.html#330

Custom networks
---------------

When creating a network, extra options can be provided.

  *  :code:`--internal` disables outbound traffic (the network won't have a default gateway).
  *  :code:`--gateway` indicates which address to use for the gateway (when outbound traffic is allowed).
  *  :code:`--subnet` (in CIDR notation) indicates the subnet to use.
  *  :code:`--ip-range` (in CIDR notation) indicates the subnet to allocate from.
  *  :code:`--aux-address` allows specifying a list of reserved addresses (which won't be allocated to containers).
  *  Reference: https://container.training/intro-selfpaced.yml.html#362

Connecting and Disconnecting from networks dynamically
------------------------------------------------------

  *  The Docker Engine also allows connecting and disconnecting while the container is running.
  *  This feature is exposed through the Docker API, and through two Docker CLI commands:
        *  :code:`docker network connect <network> <container>`
        *  :code:`docker network disconnect <network> <container>`
  *  Reference: https://container.training/intro-selfpaced.yml.html#367 

Docker Capabilities
-------------------

With OVS being run as a container, it needs some privileges to access network and system resources.  In Docker, this is controlled by providing `"Capability" <https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities>`_ permissions to the running container.  For OVS to work, Capabilities such as ``"SYS_MODULE"``, ``"NET_ADMIN"`` and ``"SYS_NICE"`` are required.

A very useful picture to understand Capabilities is available at https://twitter.com/b0rk/status/1217168566556004352/photo/1

.. code-block:: text

    Capability Key       Capability Description
    ===========================================
    SYS_MODULE       Load and unload kernel modules.
    SYS_RAWIO        Perform I/O port operations (iopl(2) and ioperm(2)).
    SYS_PACCT        Use acct(2), switch process accounting on or off.
    SYS_ADMIN        Perform a range of system administration operations.
    SYS_NICE         Raise process nice value (nice(2), setpriority(2)) and change the nice value for arbitrary processes.
    SYS_RESOURCE     Override resource Limits.
    SYS_TIME         Set system clock (settimeofday(2), stime(2), adjtimex(2)); set real-time (hardware) clock.
    SYS_TTY_CONFIG   Use vhangup(2); employ various privileged ioctl(2) operations on virtual terminals.
    AUDIT_CONTROL    Enable and disable kernel auditing; change auditing filter rules; retrieve auditing status and filtering rules.
    MAC_ADMIN        Allow MAC configuration or state changes. Implemented for the Smack LSM.
    MAC_OVERRIDE     Override Mandatory Access Control (MAC). Implemented for the Smack Linux Security Module (LSM).
    NET_ADMIN        Perform various network-related operations.
    SYSLOG           Perform privileged syslog(2) operations.
    DAC_READ_SEARCH  Bypass file read permission checks and directory read and execute permission checks.
    LINUX_IMMUTABLE  Set the FS_APPEND_FL and FS_IMMUTABLE_FL i-node flags.
    NET_BROADCAST    Make socket broadcasts, and listen to multicasts.
    IPC_LOCK         Lock memory (mlock(2), mlockall(2), mmap(2), shmctl(2)).
    IPC_OWNER        Bypass permission checks for operations on System V IPC objects.
    SYS_PTRACE       Trace arbitrary processes using ptrace(2).
    SYS_BOOT         Use reboot(2) and kexec_load(2), reboot and load a new kernel for later execution.
    LEASE            Establish leases on arbitrary files (see fcntl(2)).
    WAKE_ALARM       Trigger something that will wake up the system.
    BLOCK_SUSPEND    Employ features that can block system suspend.


From http://man7.org/linux/man-pages/man7/capabilities.7.html

.. code-block:: text

    CAP_NET_ADMIN
            Perform various network-related operations:
            * interface configuration;
            * administration of IP firewall, masquerading, and accounting;
            * modify routing tables;
            * bind to any address for transparent proxying;
            * set type-of-service (TOS)
            * clear driver statistics;
            * set promiscuous mode;
            * enabling multicasting;
            * use setsockopt(2) to set the following socket options:
            SO_DEBUG, SO_MARK, SO_PRIORITY (for a priority outside the
            range 0 to 6), SO_RCVBUFFORCE, and SO_SNDBUFFORCE.
    CAP_NET_RAW
            * Use RAW and PACKET sockets;
            * bind to any address for transparent proxying.
    CAP_SYS_ADMIN
            Note: this capability is overloaded; see Notes to kernel
            developers, below.

            * Perform a range of system administration operations
            including: quotactl(2), mount(2), umount(2), pivot_root(2),
            setdomainname(2);
            * perform privileged syslog(2) operations (since Linux 2.6.37,
            CAP_SYSLOG should be used to permit such operations);
            * perform VM86_REQUEST_IRQ vm86(2) command;
            * perform IPC_SET and IPC_RMID operations on arbitrary System
            V IPC objects;
            * override RLIMIT_NPROC resource limit;
            * perform operations on trusted and security Extended
            Attributes (see xattr(7));
            * use lookup_dcookie(2);
            * use ioprio_set(2) to assign IOPRIO_CLASS_RT and (before
            Linux 2.6.25) IOPRIO_CLASS_IDLE I/O scheduling classes;
            * forge PID when passing socket credentials via UNIX domain
            sockets;
            * exceed /proc/sys/fs/file-max, the system-wide limit on the
            number of open files, in system calls that open files (e.g.,
            accept(2), execve(2), open(2), pipe(2));
            * employ CLONE_* flags that create new namespaces with
            clone(2) and unshare(2) (but, since Linux 3.8, creating user
            namespaces does not require any capability);
            * call perf_event_open(2);
            * access privileged perf event information;
            * call setns(2) (requires CAP_SYS_ADMIN in the target
            namespace);
            * call fanotify_init(2);
            * call bpf(2);
            * perform privileged KEYCTL_CHOWN and KEYCTL_SETPERM keyctl(2)
            operations;
            * perform madvise(2) MADV_HWPOISON operation;
            * employ the TIOCSTI ioctl(2) to insert characters into the
            input queue of a terminal other than the caller's
            controlling terminal;
            * employ the obsolete nfsservctl(2) system call;
            * employ the obsolete bdflush(2) system call;
            * perform various privileged block-device ioctl(2) operations;
            * perform various privileged filesystem ioctl(2) operations;
            * perform privileged ioctl(2) operations on the /dev/random
            device (see random(4));
            * install a seccomp(2) filter without first having to set the
            no_new_privs thread attribute;
            * modify allow/deny rules for device control groups;
            * employ the ptrace(2) PTRACE_SECCOMP_GET_FILTER operation to
            dump tracee's seccomp filters;
            * employ the ptrace(2) PTRACE_SETOPTIONS operation to suspend
            the tracee's seccomp protections (i.e., the
            PTRACE_O_SUSPEND_SECCOMP flag);
            * perform administrative operations on many device drivers.
    CAP_SYS_MODULE
            * Load and unload kernel modules (see init_module(2) and
            delete_module(2));
            * in kernels before 2.6.25: drop capabilities from the system-
            wide capability bounding set.

Namespaces Refresher Tutorial
=============================

Let's first understand what network namespaces are. So basically, when you install Linux, by default the entire OS share the same routing table and the same IP address. The namespace forms a cluster of all global system resources which can only be used by the processes within the namespace, providing resource isolation.

Docker containers use this technology to form their own cluster of resources which would be used only by that namespace, i.e. that container. Hence every container has its own IP address and work in isolation without facing resource sharing conflicts with other containers running on the same system.

Linux’s network namespaces are used to glue container processes and the host networking stack. Docker spawns a container in the containers own network namespace (use the CLONE_NEWNET flag defined in sched.h when calling the clone system call to create a new network namespace for the subprocess) and later on runs a veth pair (a cable with two ends) between the container namespace and the host network stack.

IP Tables
=========

Docker extensively uses ``iptables`` to provide isolation amongst its services and filtering of traffic. Mostly, we may never have to touch this feature unless, the underlying system has a custom ``iptables`` rules.


References
==========

  *  Docker - https://docker.com
  *  Fedora CoreOS - https://getfedora.org/coreos/
  *  Container Tutorial - https://container.training/intro-selfpaced.yml.html#1
  *  Useful ``iptable`` commands - https://www.cyberciti.biz/tips/linux-iptables-examples.html 
  *  Linux Netdev - https://arthurchiao.github.io/blog/ovs-deep-dive-4-patch-port/  - Read about why type=system, type=netdev, type=internal, etc are used with ovs-vsctl add-port command
  *  Namespaces - https://www.edureka.co/community/33605/what-network-namespace-access-network-namespace-container
  *  Docker and Network namespaces - https://platform9.com/blog/container-namespaces-deep-dive-container-networking/
  *  Capabilities - a quick cartoon style tutorial - https://twitter.com/b0rk/status/1217168566556004352/photo/1
