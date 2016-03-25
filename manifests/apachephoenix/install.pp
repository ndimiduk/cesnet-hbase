# install the phoenix bits
class hbase::apachephoenix::install {
  # install phoenix from tgz.
  # inspired by https://github.com/viirya/puppet-hbase/blob/master/manifests/init.pp

  if $hbase::phoenix_version == undef {
    err('attempt to use hbase::apachephoenix without setting hbase::phoenix_version.')
    fail()
  }

  $phoenix_tgz_url = $hbase::phoenix_tgz_url ? {
    undef   => "http://www-us.apache.org/dist/phoenix/phoenix-${hbase::phoenix_version}/bin/phoenix-${hbase::phoenix_version}-bin.tar.gz",
    default => $hbase::phoenix_tgz_url
  }
  $phoenix_install_dir = $hbase::phoenix_install_dir ? {
    undef   => "/usr/hdp/${hbase::phoenix_version}",
    default => $hbase::phoenix_install_dir
  }

  file { $phoenix_install_dir:
    ensure => directory,
    owner  => 'hbase',
    group  => 'hadoop',
    mode   => '0755',
  }

  $_cmd = $hbase::auth_token ? {
    undef   => "wget ${phoenix_tgz_url}",
    default => "curl -O -J -L -H 'Accept:application/octet-stream' -u '${hbase::auth_token}:' ${phoenix_tgz_url}"
  }

  exec { "download ${phoenix_tgz_url}":
    command => $_cmd,
    cwd     => $phoenix_install_dir,
    user    => 'hbase',
    path    => '/bin:/usr/bin:/usr/sbin',
    creates => "${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin.tar.gz",
    timeout => 600, # this can take a while
  }

  file { "${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin.tar.gz":
    owner => 'hbase',
    group => 'hadoop',
    mode  => '0644',
  }

  exec { "untar ${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin.tar.gz":
    command => "tar xzf ${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin.tar.gz",
    cwd     => $phoenix_install_dir,
    path    => '/bin:/usr/bin:/usr/sbin',
    creates => "${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin",
  }

  file { "${phoenix_install_dir}/phoenix":
    ensure => link,
    target => "phoenix-${hbase::phoenix_version}-bin",
  }

  # convienence symlinks for commonly used jars
  file { "${phoenix_install_dir}/phoenix/phoenix-client.jar":
    ensure => link,
    target => "phoenix-${hbase::phoenix_version}-client.jar",
  }
  file { "${phoenix_install_dir}/phoenix/phoenix-client-spark.jar":
    ensure => link,
    target => "phoenix-${hbase::phoenix_version}-client-spark.jar",
  }
  file { "${phoenix_install_dir}/phoenix/phoenix-server.jar":
    ensure => link,
    target => "phoenix-${hbase::phoenix_version}-server.jar",
  }

  exec { 'hdp-select phoenix-server':
    command => "hdp-select set phoenix-server ${hbase::phoenix_version}",
    path    => '/bin:/usr/bin:/usr/sbin',
    creates => '/usr/hdp/current/phoenix-server',
  }
  exec { 'hdp-select phoenix-client':
    command => "hdp-select set phoenix-client ${hbase::phoenix_version}",
    path    => '/bin:/usr/bin:/usr/sbin',
    creates => '/usr/hdp/current/phoenix-client',
  }

  # install phoenix into hbase server lib
  file { '/usr/hdp/current/hbase-master/lib/phoenix-server.jar':
    ensure => link,
    target => '/usr/hdp/current/phoenix-server/phoenix-server.jar',
  }
  file { '/usr/hdp/current/hbase-regionserver/lib/phoenix-server.jar':
    ensure => link,
    target => '/usr/hdp/current/phoenix-server/phoenix-server.jar',
  }

  File[$phoenix_install_dir] ->
  Exec["download ${phoenix_tgz_url}"] ->
  File["${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin.tar.gz"] ->
  Exec["untar ${phoenix_install_dir}/phoenix-${hbase::phoenix_version}-bin.tar.gz"] ->
  File["${phoenix_install_dir}/phoenix"]

  File["${phoenix_install_dir}/phoenix"] ->
  File["${phoenix_install_dir}/phoenix/phoenix-client.jar"]

  File["${phoenix_install_dir}/phoenix"] ->
  File["${phoenix_install_dir}/phoenix/phoenix-client-spark.jar"]

  File["${phoenix_install_dir}/phoenix"] ->
  File["${phoenix_install_dir}/phoenix/phoenix-server.jar"]

  File["${phoenix_install_dir}/phoenix"] ->
  Exec['hdp-select phoenix-server']

  File["${phoenix_install_dir}/phoenix"] ->
  Exec['hdp-select phoenix-client']

  Exec['hdp-select phoenix-server'] ->
  File['/usr/hdp/current/hbase-master/lib/phoenix-server.jar']

  Exec['hdp-select phoenix-server'] ->
  File['/usr/hdp/current/hbase-regionserver/lib/phoenix-server.jar']

  if defined(Service[$hbase::daemons['master']]) {
    File['/usr/hdp/current/hbase-regionserver/lib/phoenix-server.jar'] ~>
    Service[$hbase::daemons['master']]
  }
  if defined(Service[$hbase::daemons['regionserver']]) {
    File['/usr/hdp/current/hbase-regionserver/lib/phoenix-server.jar'] ~>
    Service[$hbase::daemons['regionserver']]
  }
}
