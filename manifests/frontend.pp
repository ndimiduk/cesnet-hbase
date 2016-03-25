# == Class hbase::frontend
#
# HBase client. Meant to be included to particular nodes. Declaration of the main hbase class with configuration is required.
#
class hbase::frontend {
  include 'hbase::frontend::install'
  include 'hbase::frontend::config'
  include 'hbase::apachephoenix::install'
  include 'hbase::apachephoenix::config'

  Class['hbase::frontend::install'] ->
  Class['hbase::frontend::config'] ->
  Class['hbase::frontend']

  if $::hbase::phoenix {
    Class['hbase::apachephoenix::install'] ->
    Class['hbase::apachephoenix::config'] ->
    Class['hbase::frontend']
  }
}
