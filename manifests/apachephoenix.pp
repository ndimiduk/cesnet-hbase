# == Class hbase::apachephoenix
#
# Phoenix SQL extensions to HBase. Installed from apache dist tarballs, not
# package manager. Meant to be included to all HBase nodes.
#
class hbase::apachephoenix {
  include ::hbase::common::config
  include ::hbase::apachephoenix::install
  include ::hbase::apachephoenix::config
  include ::hbase::apachephoenix::service

  Class['hbase::apachephoenix::install'] ->
  Class['hbase::apachephoenix::config'] ~>
  Class['hbase::apachephoenix::service'] ->
  Class['hbase::apachephoenix']

  # phoenix class impacts cluster configs
  Class['hbase::apachephoenix::config'] ->
  Class['hbase::common::config']

  # phoenix required on master and regionserver
  if defined(Class['hbase::master']) {
    Class['hbase::apachephoenix'] -> Class['hbase::master']
  }
  if defined(Class['hbase::regionserver']) {
    Class['hbase::apachephoenix'] -> Class['hbase::regionserver']
  }

  # phoenix service also depends on hbase config
  Class['hbase::common::config'] ~>
  Class['hbase::apachephoenix::service']
}
