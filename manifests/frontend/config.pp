class hbase::frontend::config {
  contain hbase::common::config

  if $hbase::external_zookeeper {
    contain hbase::common::keytab
  }

  file { $hbase::hbase_homedir:
    ensure => directory,
    owner  => 'hbase',
    group  => 'hadoop',
    mode   => '0755',
  }
  ->
  file {"${hbase::hbase_homedir}/local":
    ensure => 'directory',
    owner  => 'hbase',
    group  => 'hbase',
  }
  ->
  file {"${hbase::hbase_homedir}/local/jars":
    ensure => 'directory',
    owner  => 'hbase',
    group  => 'hbase',
  }
}
