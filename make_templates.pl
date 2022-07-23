#!/usr/bin/env perl

use warnings;
use strict;


# args:
#   box_name. (e.g. "arranstewart/cits3007-ubuntu2004")
#   host_name. (e.g. "cits3007-ubuntu2004.local")
#
# returns:
#   conts for a `developer.rb` file

sub mk_developer_rb_conts {
  my $box_name = shift;
  my $host_name = shift;

  my $conts = <<END;
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.boot_timeout = 1800
  config.vm.box = "$box_name"
  config.vm.hostname = "$host_name"
  config.vm.synced_folder ".", "/vagrant", disabled: true

end
END

  return $conts; 
}

# args:
#   author. e.g. "Arran Stewart"
#   website. e.g. "https://github.com/cits3007"
#   repository. eg. "https://github.com/cits3007/ubuntu-vagrant-box"
#       (gets used for 'Configuration' as well)
#   description. e.g. "This box contains foo and bar".
#
# returns:
#   conts for an info.json file

sub mk_info_json_conts {
  my $author  = shift;
  my $website = shift;
  my $repo    = shift;
  my $descr   = shift;

  my $conts = <<END;
{
 "Author": "$author",
 "Website": "$website",
 "Repository": "$repo",
 "Configuration": "$repo",
 "Description": "$descr"
}
END

  return $conts; 
}

my $MAKE_ARGS = "--no-print-directory";

use Data::Dumper;

my ($author, $box_name, $user_name, $host_name, $website, $repo, $descr);

my $cmd = "make $MAKE_ARGS print_author";
$author = `$cmd`;
die "couldn't execute '$cmd': $!" if $?;
chomp $author;

$cmd = "make $MAKE_ARGS print_box_name";
$box_name = `$cmd`;
die "couldn't execute '$cmd': $!" if $?;
chomp $box_name;

$cmd = "make $MAKE_ARGS print_vagrant_cloud_username";
$user_name = `$cmd`;
die "couldn't execute '$cmd': $!" if $?;
chomp $user_name;

$cmd = "make $MAKE_ARGS print_github_repo";
$repo = `$cmd`;
die "couldn't execute '$cmd': $!" if $?;
chomp $repo;

$cmd = "make $MAKE_ARGS print_desc";
$descr = `set -x && $cmd`;
die "couldn't execute '$cmd': $!" if $?;
chomp $descr;

my $developer_rb_conts = mk_developer_rb_conts("$user_name/$box_name", "${box_name}.local");

open(FH, '>', "developer.rb") or die $!;
print FH $developer_rb_conts;
close(FH);


my $info_json_conts = mk_info_json_conts($author, $repo, $repo, $descr);

open(FH, '>', "info.json") or die $!;
print FH $info_json_conts;
close(FH);

