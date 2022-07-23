
# useful tips

## VMDK info

A handy command for displaying info about a .vmdk file is:

```
vboxmanage showmediuminfo /path/to/img.vmdk
```

It shows the file format version, and what disk variant is being used (streaming, fixed, etc.)

## Building an .ova file

It would be nice if we could just download an OVA file from the Vagrant cloud,
but it appears that the generic/ubuntu2004 box consists of a version 1 OVA file,
but packer only works with version 2 OVA files. So we have to instead re-package
the OVA file using `make_ova.pl` (which used as a template the output of doing an
"export" from a recent version of VirtualBox).


