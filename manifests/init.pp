# Class: gfarm
#
# This module manages gfarm
#
class gfarm (
  $package_ensure = latest,
  $gfm_host       = 'localhost',
  $cred_dir       = '/etc/grid-security/gfarm/',
) {
  file { '/etc/gfarm2.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('gfarm/gfarm2.conf.erb'),
  }
}
