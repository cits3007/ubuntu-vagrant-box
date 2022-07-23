
# various variables, typically
# got from environment

variable "SOURCE_PATH" {
  type        = string
  description = "path to input .img QCOW2 file"
}

variable "SOURCE_MD5" {
  type        = string
  description = "md5 hash of QCOW2 file"
}

variable "DISK_SIZE" {
  type        = number
  description = "size of disk in bytes"
}

variable "OUTPUT_DIR" {
  type        = string
  description = "output dir"
}

variable "BOX_NAME" {
  type        = string
  description = "name of box being created"
}

variable "BOX_VERSION" {
  type        = string
  description = "version of box being created"
}

source "qemu" "cits3007" {

  iso_url           = "file:///${var.SOURCE_PATH}"
  disk_image        = true
  format            = "qcow2"
  iso_checksum      = "md5:${var.SOURCE_MD5}"

  shutdown_command  = "sudo shutdown -P now"

  communicator      = "ssh"
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  ssh_timeout       = "60m"

  headless          = true

  # Needn't specify an accelerator - packer docco
  # says kvm will be used by default if available,
  # else tcg: https://www.packer.io/docs/builders/qemu.

  #accelerator       = "kvm"

  output_directory  = "${var.OUTPUT_DIR}"

  disk_size         = "${var.DISK_SIZE}b"
  vm_name           = "${var.BOX_NAME}_${var.BOX_VERSION}.qcow2"

  net_device        = "virtio-net"
  disk_interface    = "virtio-scsi"
  boot_wait         = "20s"

  display           = "none"

  # needed, see https://github.com/hashicorp/packer/issues/8693
  # (??still)
  qemuargs         = [
      ["-display", "none"]
    ]
}


build {
  sources = ["source.qemu.cits3007"]

  provisioner "shell" {
      scripts = [
        "../provision-01.sh",
        "../provision-02.sh"
      ]
      execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
      timeout = "60m"
      max_retries = 2
  }

  post-processors {

    post-processor "vagrant" {

       compression_level = 9
       keep_input_artifact = true
       vagrantfile_template = "developer.rb"
       output = "${var.OUTPUT_DIR}/${var.BOX_NAME}_${var.BOX_VERSION}.box"
       include = [
           "info.json"
       ]
    }

    post-processor "checksum" {
      checksum_types = ["md5"]
      output = "${var.OUTPUT_DIR}/${var.BOX_NAME}_${var.BOX_VERSION}.box.md5"
    }

  }

}
