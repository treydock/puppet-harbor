# @api private
# @summary Sets up a systemd unit file and service for Harbor
class harbor::service (
  $cfg_version,
){
  assert_private()

  $_compose_files = '-f /opt/harbor/docker-compose.yml'

  file { 'harbor_service_unit':
    ensure  => file,
    path    => '/etc/systemd/system/harbor.service',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('harbor/harbor.service.epp', {
        'compose_files' => $_compose_files,
    }),
    notify  => Exec['harbor_systemd_daemon-reload'],
  }

  exec { 'harbor_systemd_daemon-reload':
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'systemctl daemon-reload > /dev/null',
    refreshonly => true,
  }

  service { 'harbor':
    ensure    => running,
    enable    => true,
    subscribe => Exec['harbor_systemd_daemon-reload'],
  }
}
