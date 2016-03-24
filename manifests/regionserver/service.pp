class hbase::regionserver::service {

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hbase-regionserver.conf':
    ensure  => file,
    content => template('hbase/services/hbase-regionserver.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  service { $hbase::daemons['regionserver']:
    ensure => running,
    enable => true,
  }

  File['/etc/init/hbase-regionserver.conf'] ~> Service[$hbase::daemons['regionserver']]
}
