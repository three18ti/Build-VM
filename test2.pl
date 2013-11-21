#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;


use lib 'lib';
use Build::VM;

my $hvm_address = '192.168.0.35';

my $bvm = Build::VM->new(
    base_image_name   => 'ubuntu-server-13.10-x86_64-base',
    snap_name         => '2013-11-13',
    guest_name        => 'build_vm_test',
    guest_memory      => 4096,
    storage_disk_size => 20,
    rbd_hosts         => [qw(192.168.0.35 192.168.0.2 192.168.0.40)],
    hvm_address       => $hvm_address,
    template_name     => 'server-no-config.tt',
);

#is_deeply $bvm->host->, "192.168.0.35192.168.0.2192.168.0.40",
#    "rbd hosts are as expected";
#is $bvm->guest_xml, get_template_xml(),
#    "template is generated properly";

# This works... dunno how to test it though
#my @disk_names = map { [$_, 20] } ( "a" .. "zzz");
#my $disk_list = $bvm->build_disk_list(\@disk_names);
#my @expected_names = map { [$_, "vd" . $_ ] } ( "a" .. "zzz" );
#is_deply $disk_list, \@expected_names, "Disk lists are correct";
#use Data::Dump;
#print dd $disk_list;

#$bvm->build_disks;
#my $dom = $bvm->deploy_ephemeral;

say "Check vm built now";
system "virsh list";

$bvm->hvm->vm_list;

#$dom->destroy;
#$dom->undefine;

#$bvm->remove_disks;

sub get_template_xml{
return<<TEMPLATE_XML
<domain type='kvm'>
  <name>build_vm_test</name>
  <memory unit='KiB'>4194304</memory>
  <currentMemory unit='KiB'>4194304</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-1.4'>hvm</type>
    <boot dev='hd'/>
    <bootmenu enable='no'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type='network' device='disk'>
      <driver name='qemu'/>
      <source protocol='rbd' name='libvirt-pool/build_vm_test-os'>
        <host name='192.168.0.35' port='6789'/>
        <host name='192.168.0.2' port='6789'/>
        <host name='192.168.0.40' port='6789'/>
      </source>
      <target dev='vda' bus='virtio' />
    </disk>
    <disk type='network' device='disk'>
      <driver name='qemu'/>
      <source protocol='rbd' name='libvirt-pool/build_vm_test-storage'>
        <host name='192.168.0.35' port='6789'/>
        <host name='192.168.0.2' port='6789'/>
        <host name='192.168.0.40' port='6789'/>
      </source>
      <target dev='vdb' bus='virtio' />
    </disk>  

    <interface type='bridge'>
      <source bridge='ovsbr0'/>
      <virtualport type='openvswitch'>
      </virtualport>
      <model type='virtio'/>
    </interface>

    <controller type='usb' index='0'>
    </controller>
    <controller type='ide' index='0'>
    </controller>
    <controller type='virtio-serial' index='0'>
    </controller>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes'/>
    <sound model='ich6'>
    </sound>

    <video>
      <model type='cirrus' vram='9216' heads='1'/>
    </video>

    <memballoon model='virtio'>
    </memballoon>

  </devices>
</domain>
TEMPLATE_XML
}

__END__
use Template;


my $tt = Template->new({

}) || die "$Template::ERROR\n";

my $output = '';
use Build::VM::Guest;
use Build::VM::System;
$tt->process(
    'server-base.tt',    
    {
        guest   =>  Build::VM::Guest->new(
                    name    => 'foo-test',
                    memory  => 2048 * 1024,
                    disk_list   => [qw(foo-test1 foo-test2)],
                    cdrom       => '/media/ubuntu-13.10-server-amd64.iso',
                ),
        system  =>  Build::VM::System->new(
                    rbd_hosts_list   => [qw(192.168.0.2 192.168.0.35 192.168.0.40)],
                ),
    },
    'server-base.out'
);

done_testing;
