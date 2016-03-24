class hbase::master::service {

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hbase-master.conf':
    ensure  => file,
    content => template('hbase/services/hbase-master.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  service { $hbase::daemons['master']:
    ensure => running,
    enable => true,
  }

  File['/etc/init/hbase-master.conf'] ~> Service[$hbase::daemons['master']]
}
