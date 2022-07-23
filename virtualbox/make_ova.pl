#!/usr/bin/env perl

use warnings;
use strict;

use File::Basename;
use File::Path qw(make_path);
use File::Copy qw(copy);

sub mk_uuid {
  # make UUIDs even on MacOS, where it needs to be lowercased
  my $cmd = "uuidgen | tr '[:upper:]' '[:lower:]'";
  print STDERR "+ $cmd\n";
  my $res = `$cmd`;
  die "couldn't execute '$cmd': $!" if $?;
  chomp $res;
  return $res;
}

# args:
# - input file
sub sha256sum {
  my $input_file = shift;

  my $cmd = "sha256sum $input_file";
  print STDERR "+ $cmd\n";
  my $res = `$cmd`;
  die "couldn't execute '$cmd': $!" if $?;
  chomp $res;
  my ($sum, $_stuff) = split(' ', $res);
  return $sum;
}

# arg:
# hash config with keys:
#  - vmdk_file
#  - vmdk_uuid
#  - vm_id (e.g. 'generic-ubuntu2004-virtualbox', 'cits3007_ubu2004_inst')
#  - vm_uuid (e.g. '453ae8b4-099a-11ed-861d-0242ac120002')
#  - memory_mb (e.g. `2048`)

sub mk_ovf_conts {

  my $config = shift;

  my $ovf_template = <<"END"
<?xml version="1.0"?>
<Envelope ovf:version="2.0" xml:lang="en-US" xmlns="http://schemas.dmtf.org/ovf/envelope/2" xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/2" xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:vbox="http://www.virtualbox.org/ovf/machine" xmlns:epasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_EthernetPortAllocationSettingData.xsd" xmlns:sasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_StorageAllocationSettingData.xsd">
  <References>
    <File ovf:id="file1" ovf:href="$config->{'vmdk_file'}"/>
  </References>
  <DiskSection>
    <Info>List of the virtual disks used in the package</Info>
    <Disk ovf:capacity="137438953472" ovf:diskId="vmdisk1" ovf:fileRef="file1" ovf:format="http://www.vmware.com/interfaces/specifications/vmdk.html#streamOptimized" vbox:uuid="$config->{'vmdk_uuid'}"/>
  </DiskSection>
  <NetworkSection>
    <Info>Logical networks used in the package</Info>
    <Network ovf:name="NAT">
      <Description>Logical network used by this appliance.</Description>
    </Network>
  </NetworkSection>
  <VirtualSystem ovf:id="$config->{'vm_id'}">
    <Info>A virtual machine</Info>
    <OperatingSystemSection ovf:id="94">
      <Info>The kind of installed guest operating system</Info>
      <Description>Ubuntu_64</Description>
      <vbox:OSType ovf:required="false">Ubuntu_64</vbox:OSType>
    </OperatingSystemSection>
    <VirtualHardwareSection>
      <Info>Virtual hardware requirements for a virtual machine</Info>
      <System>
        <vssd:ElementName>Virtual Hardware Family</vssd:ElementName>
        <vssd:InstanceID>0</vssd:InstanceID>
        <vssd:VirtualSystemIdentifier>$config->{'vm_id'}</vssd:VirtualSystemIdentifier>
        <vssd:VirtualSystemType>virtualbox-2.2</vssd:VirtualSystemType>
      </System>
      <Item>
        <rasd:Caption>2 virtual CPU</rasd:Caption>
        <rasd:Description>Number of virtual CPUs</rasd:Description>
        <rasd:InstanceID>1</rasd:InstanceID>
        <rasd:ResourceType>3</rasd:ResourceType>
        <rasd:VirtualQuantity>2</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:AllocationUnits>MegaBytes</rasd:AllocationUnits>
        <rasd:Caption>$config->{'memory_mb'} MB of memory</rasd:Caption>
        <rasd:Description>Memory Size</rasd:Description>
        <rasd:InstanceID>2</rasd:InstanceID>
        <rasd:ResourceType>4</rasd:ResourceType>
        <rasd:VirtualQuantity>$config->{'memory_mb'}</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:Address>0</rasd:Address>
        <rasd:Caption>ideController0</rasd:Caption>
        <rasd:Description>IDE Controller</rasd:Description>
        <rasd:InstanceID>3</rasd:InstanceID>
        <rasd:ResourceSubType>PIIX4</rasd:ResourceSubType>
        <rasd:ResourceType>5</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:Address>1</rasd:Address>
        <rasd:Caption>ideController1</rasd:Caption>
        <rasd:Description>IDE Controller</rasd:Description>
        <rasd:InstanceID>4</rasd:InstanceID>
        <rasd:ResourceSubType>PIIX4</rasd:ResourceSubType>
        <rasd:ResourceType>5</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:Address>0</rasd:Address>
        <rasd:Caption>sataController0</rasd:Caption>
        <rasd:Description>SATA Controller</rasd:Description>
        <rasd:InstanceID>5</rasd:InstanceID>
        <rasd:ResourceSubType>AHCI</rasd:ResourceSubType>
        <rasd:ResourceType>20</rasd:ResourceType>
      </Item>
      <StorageItem>
        <sasd:AddressOnParent>0</sasd:AddressOnParent>
        <sasd:Caption>disk1</sasd:Caption>
        <sasd:Description>Disk Image</sasd:Description>
        <sasd:HostResource>/disk/vmdisk1</sasd:HostResource>
        <sasd:InstanceID>6</sasd:InstanceID>
        <sasd:Parent>5</sasd:Parent>
        <sasd:ResourceType>17</sasd:ResourceType>
      </StorageItem>
      <EthernetPortItem>
        <epasd:AutomaticAllocation>true</epasd:AutomaticAllocation>
        <epasd:Caption>Ethernet adapter on 'NAT'</epasd:Caption>
        <epasd:Connection>NAT</epasd:Connection>
        <epasd:InstanceID>7</epasd:InstanceID>
        <epasd:ResourceSubType>E1000</epasd:ResourceSubType>
        <epasd:ResourceType>10</epasd:ResourceType>
      </EthernetPortItem>
    </VirtualHardwareSection>
    <vbox:Machine ovf:required="false" version="1.16-linux" uuid="{$config->{'vm_uuid'}}" name="$config->{'vm_id'}" OSType="Ubuntu_64" snapshotFolder="Snapshots" lastStateChange="2022-07-22T07:30:26Z">
      <ovf:Info>Complete VirtualBox machine configuration in VirtualBox format</ovf:Info>
      <Hardware>
        <CPU count="2">
          <PAE enabled="true"/>
          <LongMode enabled="true"/>
          <X2APIC enabled="true"/>
          <HardwareVirtExLargePages enabled="false"/>
        </CPU>
        <Memory RAMSize="$config->{'memory_mb'}"/>
        <Boot>
          <Order position="1" device="HardDisk"/>
          <Order position="2" device="DVD"/>
          <Order position="3" device="None"/>
          <Order position="4" device="None"/>
        </Boot>
        <Display VRAMSize="256"/>
        <VideoCapture screens="1" file="." fps="25"/>
        <RemoteDisplay enabled="true">
          <VRDEProperties>
            <Property name="TCP/Address" value="127.0.0.1"/>
            <Property name="TCP/Ports" value="11682"/>
          </VRDEProperties>
        </RemoteDisplay>
        <BIOS>
          <IOAPIC enabled="true"/>
        </BIOS>
        <Network>
          <Adapter slot="0" enabled="true" MACAddress="0800277A02C1" type="82540EM">
            <NAT>
              <DNS use-proxy="true"/>
              <Forwarding name="ssh" proto="1" hostip="127.0.0.1" hostport="2222" guestport="22"/>
            </NAT>
          </Adapter>
        </Network>
        <AudioAdapter driver="ALSA" enabledIn="false" enabledOut="false"/>
        <RTC localOrUTC="UTC"/>
        <Clipboard/>
      </Hardware>
      <StorageControllers>
        <StorageController name="IDE Controller" type="PIIX4" PortCount="2" useHostIOCache="true" Bootable="true"/>
        <StorageController name="SATA Controller" type="AHCI" PortCount="1" useHostIOCache="false" Bootable="true" IDE0MasterEmulationPort="0" IDE0SlaveEmulationPort="1" IDE1MasterEmulationPort="2" IDE1SlaveEmulationPort="3">
          <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
            <Image uuid="{$config->{'vmdk_uuid'}}"/>
          </AttachedDevice>
        </StorageController>
      </StorageControllers>
    </vbox:Machine>
  </VirtualSystem>
</Envelope>

END
;

  return $ovf_template;

}

# args:
# - ovf_file - full path to .ovf file
# - vmdk_file - full path to .vmdk file
#
# Creates the conts of an .mf file
sub mk_mf_conts {
  my $ovf_file  = shift;
  my $vmdk_file = shift;

  my $base_ovf_file   = basename($ovf_file);
  my $base_vmdk_file  = basename($vmdk_file);


  my $ovf_sha256  = sha256sum($ovf_file);
  my $vmdk_sha256 = sha256sum($vmdk_file);

  my $res = <<EOF;
SHA256 ($base_ovf_file) = $ovf_sha256
SHA256 ($base_vmdk_file) = $vmdk_sha256
EOF

  return $res;
}

# hard-coded RAM size
my $MEMORY_MB = 2048;

# args:
# - $vm_id
# - $vmdk_file
# - $output_dir

sub mk_ova_file {
  my $vm_id       = shift;
  my $vmdk_file   = shift;
  my $output_dir  = shift;

  my $base_vmdk_file = basename($vmdk_file);
  my $new_vmdk_file  = "${vm_id}-disk001.vmdk";
  
  make_path($output_dir);

  # new vmdk file
  print STDERR "+ copy '$vmdk_file' to '$output_dir/$new_vmdk_file'\n";
  copy($vmdk_file, "$output_dir/$new_vmdk_file");

  # create .ovf file
  my $vmdk_uuid = mk_uuid();
  my $vm_uuid = mk_uuid();

  my $config = {
        'vmdk_file' => $new_vmdk_file,
        'vmdk_uuid' => $vmdk_uuid,
        'vm_id'     => $vm_id,
        'vm_uuid'   => $vm_uuid,
        'memory_mb' => $MEMORY_MB
  };

  my $ovf_file = "${vm_id}.ovf";
  open(FH, '>', "$output_dir/$ovf_file") or die $!;
  print FH (mk_ovf_conts($config));
  close(FH);

  # create .mf file
  my $mf_conts = mk_mf_conts("$output_dir/$ovf_file",
                             "$output_dir/$new_vmdk_file"
  );

  my $mf_file = "${vm_id}.mf";
  open(FH, '>', "$output_dir/$mf_file") or die $!;
  print FH $mf_conts;
  close(FH);

  # tar them up
  my $ova_file = "${vm_id}.ova";

  my $cmd = "tar cvf $output_dir/$ova_file -C $output_dir $ovf_file $new_vmdk_file $mf_file";
  print STDERR "+ $cmd\n";
  my $res = system $cmd;
  die "couldn't execute '$cmd': $!" if $?;

  print "Created $output_dir/$ova_file\n";

}

if ((scalar @ARGV) != 3) {
  my $mesg = <<END;
expected 3 args: 

- vm_id (e.g. 'generic-ubuntu2004-virtualbox', 'cits3007_ubu2004_inst')
- path/to/vmdk_file
- path to output dir
END

  print STDERR $mesg;
  exit 1;
}

my $vm_id       = $ARGV[0]; shift @ARGV;
my $vmdk_file   = $ARGV[0]; shift @ARGV;
my $output_dir  = $ARGV[0]; shift @ARGV;


mk_ova_file($vm_id, $vmdk_file, $output_dir);

