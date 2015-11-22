# Class: gfarm::gridftp
#
# Installs Globus Toolkit GridFTP server with gfarm DSI
#
class gfarm::gridftp (
) inherits gfarm {
  include gridcert::crl
  require gridcert

  package { 'globus-gridftp-server-progs':
    ensure => present,
  }
  file { '/etc/sysconfig/globus-gridftp-server':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['globus-gridftp-server-progs'],
    content => template('globus/globus-gridftp-server.erb'),
  }
  file { '/etc/gridftp.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['globus-gridftp-server-progs'],
    source  => 'puppet:///modules/globus/gridftp.conf',
  }
  file { '/etc/init.d/globus-gridftp-server':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['globus-gridftp-server-progs'],
    source  => 'puppet:///modules/globus/globus-gridftp-server',
  }
  service { 'globus-gridftp-server':
    ensure    => running,
    enable    => true,
    provider  => redhat,
    require   => [ File['/etc/sysconfig/globus-gridftp-server'], File['/etc/gridftp.conf'], File['/etc/init.d/globus-gridftp-server'] ],
  }
}
