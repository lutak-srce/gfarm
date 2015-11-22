# Define: gfarm::gfsd
#
# Sets up gfsd daemon
#
define gfarm::gfsd (
  $dir            = '/gfarm',
  $cert           = 'hostcert.pem',
  $key            = 'hostkey.pem',
  $hostname       = undef,
  $address        = undef,
  $mount          = undef,
  $mount_fstype   = 'ext3',
  $mount_options  = 'defaults',
  $mount_device   = undef,
) {
  require gfarm::fsnode
  include gridcert::package

  if $mount != undef {
    file { $mount:
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root,
    }
    mount { $mount:
      ensure  => mounted,
      atboot  => true,
      device  => $mount_device,
      fstype  => $mount_fstype,
      options => $mount_options,
      dump    => 0,
      pass    => 0,
      require => File[$mount],
    }
    $dir_full = "${mount}/${dir}"
    file { $dir_full:
      ensure  => directory,
      mode    => '0700',
      owner   => '_gfarmfs',
      group   => '_gfarmfs',
      require => Mount[$mount],
    }
  } else {
    $dir_full = $dir
    file { $dir_full:
      ensure  => directory,
      mode    => '0700',
      owner   => '_gfarmfs',
      group   => '_gfarmfs',
    }
  }

  if $hostname != undef and $address != undef {
    $hostname_str = "-h ${hostname}"
    $address_str  = "-l ${address}"
    $cert_str     = "${hostname}-${cert}"
    $key_str      = "${hostname}-${key}"
    $gfsd_service = "gfsd-${address}"
  } else {
    $hostname_str = ''
    $address_str = ''
    $cert_str = $cert
    $key_str = $key
    $gfsd_service = 'gfsd'
  }
  $cert_path = "${gfarm::fsnode::cred_dir}/${cert_str}"
  $key_path  = "${gfarm::fsnode::cred_dir}/${key_str}"

  # install certificate
  # cred_dir is created by gfarm::fsnode
  file { $cert_path:
    ensure  => file,
    owner   => '_gfarmfs',
    group   => '_gfarmfs',
    mode    => '0444',
    source  => "puppet:///private/gfarm/${cert_str}",
    require => [ File[$gfarm::fsnode::cred_dir], Package['lcg-CA'], ],
    notify  => Service[$gfsd_service],
  }
  file { $key_path:
    ensure  => file,
    owner   => '_gfarmfs',
    group   => '_gfarmfs',
    mode    => '0400',
    source  => "puppet:///private/gfarm/${key_str}",
    require => [ File[$gfarm::fsnode::cred_dir], Package['lcg-CA'], ],
    notify  => Service[$gfsd_service],
  }

  file { "/etc/init.d/${gfsd_service}":
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['globus-gridftp-server-progs'],
    content => template('gfarm/gfsd.erb'),
    notify  => Service[$gfsd_service],
  }
  service { $gfsd_service:
    ensure    => running,
    enable    => true,
    provider  => redhat,
    require   => [ File['/etc/gfarm2.conf'], File[$dir_full], File[$cert_path], File[$key_path], File["/etc/init.d/${gfsd_service}"] ],
  }
}
