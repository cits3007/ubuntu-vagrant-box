
# various variables, typically
# got from environment

variable "SOURCE_PATH" {
  type        = string
  description = "path to input .ova file"
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

source "virtualbox-ovf" "cits3007" {

  source_path       = "${var.SOURCE_PATH}"
  output_directory  = "${var.OUTPUT_DIR}"
  shutdown_command  = "sudo shutdown -P now"

  communicator      = "ssh"
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  ssh_timeout       = "60m"

  headless          = true

}


build {
  sources = ["source.virtualbox-ovf.cits3007"]

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
