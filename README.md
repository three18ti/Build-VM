[![Build Status](https://secure.travis-ci.org/three18ti/Build-VM.png?branch=cluster)](https://travis-ci.org/three18ti/Build-VM)

App to build RBD based libvirt virtual machines

App is able to build disks and vm.  See t/01_build_vm.t for usage examples.
Currently requires base vm to be built, snapshot name to be specified.

TODO:
    - Rewrite bin/vm-gen.pl to take cli / yaml config parameters - takes yaml config parameters

    - handle snapshot name generation / discovery

    - tool to build base vm for cloning, handle vm snapshotting/protect - able to clone and build base vm based on yml config

    + update build_disk_list to build list using ++ iterator - done

    - refactor template to use external disk template, this will also allow tool to create / attach disk on the fly

        - refactor template to utilize external templates?  Would allow for more versatile config

    - implement sys-prep

        - automatic ip discovery?

    - make module "cluster aware"

        - will need to impliment some sort of way to chose host/handle single host "clusters"

        - migrate vms uisng tool

        - handle situation where single hvm in cluster is unreachable

    - tool to manage vm-migration 

    - able to deploy to different ceph pools (matter of how I'm calling rbd?)
