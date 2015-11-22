# Class: gfarm::fsnode
#
# Installs Gfram fsnode
#
class gfarm::fsnode (
  $package_ensure = $gfarm::package_ensure,
  $cred_dir       = $gfarm::cred_dir,
) inherits gfarm {
  package { 'gfarm-gsi-fsnode':
    ensure => $package_ensure,
  }
  file { $cred_dir:
    ensure  => directory,
    mode    => '0755',
    owner   => root,
    group   => root,
  }
}
