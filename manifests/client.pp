# Class: gfarm::client
#
# Installs Gfram client tools and gfarm2fs
#
class gfarm::client (
  $package_ensure = $gfarm::package_ensure,
) inherits gfarm {
  package { 'gfarm-gsi-client':
    ensure => $package_ensure,
  }
  package { 'gfarm-gsi-doc':
    ensure => $package_ensure,
  }
  package { 'gfarm2fs':
    ensure => latest,
  }
}
