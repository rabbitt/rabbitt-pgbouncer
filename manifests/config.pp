# Class: pgbouncer::config
# ===========================
#
# Parameters
# ----------
#
# Package Settings:
# * `package_name`
# [string] Specifies the name of the package to use when installing pgbouncer.
#
# * `package_ensure`
# [string] Sets the version, or ensure state (e.g., present, absent, 1.6.1)
#
# Service Settings:
# * `service_enable`
# [bool] Specifies whether the service should start at runtime or not.
#
# * `service_ensure`
# [string] Specifies the state this service should always be in (e.g., running).
#
# Responsibilities:
# * `manage_package`
# [bool] If false, you will need to manually install pgbouncer. Otherwise, uses
# the package name and ensure values to install pgbouncer.
#
# * `manage_service`
# [bool] If false, the pgbouncer service will not be managed by this module.
#
# * `manage_dbconf`
# [bool] If false, the database config file will be created and populated if it
# doesn't exist, but otherwise unmanaged by this puppet module.
#
# Miscellaneous Paths:
# * `config_file`
# [string] Path to the config file containing the general pgbouncer settings.
# Default: /etc/pgbouncer/pgbouncer.ini
#
# * `db_config_file`
# [string] Path to the config file containing the list of database definitions.
# Default: /etc/pgbouncer/database.ini
#
# Generic settings:
#
# * `logfile`
# Specifies log file. Log file is kept open so after rotation kill -HUP or on
# console RELOAD; should be done. Note: On Windows machines, the service must
# be stopped and started.
# Default: not set.
#
# * `pidfile`
# Specifies the pid file. Without a pidfile, daemonization is not allowed.
# Default: not set.
#
# * `listen_addr`
# Specifies list of addresses, where to listen for TCP connections. You may also
# use * meaning "listen on all addresses". When not set, only Unix socket
# connections are allowed. Addresses can be specified numerically (IPv4/IPv6) or
# by name.
# Default: not set
#
# * `listen_port`
# Which port to listen on. Applies to both TCP and Unix sockets.
# Default: 6432
#
# * `unix_socket_dir`
# Specifies location for Unix sockets. Applies to both listening socket and server
# connections. If set to an empty string, Unix sockets are disabled. Required
# for online reboot (-R) to work.
# Default: /tmp
#
# * `unix_socket_mode`
# Filesystem mode for unix socket.
# Default: 0777
#
# * `unix_socket_group`
# Group name to use for unix socket.
# Default: not set
#
# * `user`
# If set, specifies the Unix user to change to after startup. Works only if
# PgBouncer is started as root or if it's already running as given user.
# Default: not set
#
# * `auth_file`
# The name of the file to load user names and passwords from. The file format is
# the same as the PostgreSQL 8.x pg_auth/pg_pwd file, so this setting can be
# pointed directly to one of those backend files. Since version 9.0, PostgreSQL
# does not use such text file, so it must be generated manually. See section
# below about details.
# Default: /etc/pgbouncer/userlist.txt
#
# * `auth_hba_file`
# HBA configuration file to use when  is hba.
# Default: not set
#
# * `auth_type`
# How to authenticate users.
# *hba*:
#    Actual auth type is loaded from. This allows different authentication methods
#    different access paths.
#
#    Example: connection over unix socket use peer auth method, connection over
#    TCP must use TLS.
#
# *cert*:
#    Client must connect over TLS connection with valid client cert.
#    Username is then taken from CommonName field from certificate.
#
# *md5*:
#    Use MD5-based password check.  may contain both MD5-encrypted or
#    plain-text passwords. This is the default authentication method.
#
# *plain*:
#    Clear-text password is sent over wire. Deprecated.
# *trust*:
#    No authentication is done. Username must still exist in .
# *any*:
#    Like the trust method, but the username given is ignored. Requires that all
#    databases are configured to log in as specific user. Additionally, the
#    console database allows any user to log in as admin.
#
# * `auth_query`
# Query to load user's password from db.
# Default: SELECT usename, passwd FROM pg_shadow WHERE usename=$1
#
# * `pool_mode`
# Specifies when a server connection can be reused by other clients.
# *session*:
#    Server is released back to pool after client disconnects. Default.
# *transaction*:
#    Server is released back to pool after transaction finishes.
# *statement*:
#    Server is released back to pool after query finishes. Long
#    transactions spanning multiple statements are disallowed in this mode.
#
# * `max_client_conn`
# Maximum number of client connections allowed. When increased then the file
# descriptor limits should also be increased. Note that actual number of file
# descriptors used is more than max_client_conn.
#
# Theoretical maximum used is:
#
#     max_client_conn + (max_pool_size * total_databases * total_users)
#
# if each user connects under its own username to server. If a database user
# is specified in connect string (all users connect under same username), the
# theoretical maximum is:
#
#     max_client_conn + (max_pool_size * total_databases)
#
# The theoretical maximum should be never reached, unless somebody deliberately
# crafts special load for it. Still, it means you should set the number of file
# descriptors to a safely high number. Search for ulimit in your favourite shell
# man page. Note: ulimit does not apply in a Windows environment.
#
# Default: 100
#
# * `default_pool_size`
# How many server connections to allow per user/database pair. Can be overridden
# in the per-database configuration.
#
# Default: 20
#
# * `min_pool_size`
# Add more server connections to pool if below this number. Improves behaviour
# when usual load comes suddenly back after period of total inactivity.
#
# Default: 0 (disabled)
#
# * `reserve_pool_size`
# How many additional connections to allow to a pool. 0 disables.
# Default: 0 (disabled)
#
# * `reserve_pool_timeout`
# If a client has not been serviced in this many seconds, pgbouncer enables use of
# additional connections from reserve pool. 0 disables.
#
# Default: 5.0
#
# * `max_db_connections`
# Do not allow more than this many connections per-database (regardless of pool,
# i.e. user). It should be noted that when you hit the limit, closing a client
# connection to one pool will not immediately allow a server connection to be
# established for another pool, because the server connection for the first pool
# is still open. Once the server connection closes (due to idle timeout), a new
# server connection will immediately be opened for the waiting pool.
#
# Default: unlimited
#
# * `max_user_connections`
# Do not allow more than this many connections per-user (regardless of pool - i.e.
# user). It should be noted that when you hit the limit, closing a client
# connection to one pool will not immediately allow a server connection to be
# established for another pool, because the server connection for the first pool
# is still open. Once the server connection closes (due to idle timeout), a new
# server connection will immediately be opened for the waiting pool.
#
# * `server_round_robin`
# By default, pgbouncer reuses server connections in LIFO (last-in, first-out)
# manner, so that few connections get the most load. This gives best performance
# if you have a single server serving a database. But if there is TCP round-robin
# behind a database IP, then it is better if pgbouncer also uses connections in
# that manner, thus achieving uniform load.
#
# Default: 0
#
# * `ignore_startup_parameters`
# By default, PgBouncer allows only parameters it can keep track of in startup
# packets - client_encoding, datestyle, timezone and standard_conforming_strings.
# All others parameters will raise an error. To allow others parameters, they can
# be specified here, so that pgbouncer knows that they are handled by admin and it
# can ignore them.
#
# Default: empty
#
# * `disable_pqexec`
# Disable Simple Query protocol (PQexec). Unlike Extended Query protocol, Simple
# Query allows multiple queries in one packet, which allows some classes of
# SQL-injection attacks. Disabling it can improve security. Obviously this means
# only clients that exclusively use Extended Query protocol will stay working.
#
# Default: 0
#
# * `application_name_add_host`
# Add the client host address and port to the application name setting set on
# connection start. This helps in identifying the source of bad queries etc.
# This logic applies only on start of connection, if application_name is later
# changed with SET, pgbouncer does not change it again.
#
# Default: 0
#
# * `conffile`
# Show location of current config file. Changing it will make PgBouncer use
# another config file for next RELOAD / SIGHUP.
#
# Default: file from command line.
#
# Log settings:
#
# * `syslog`
# Toggles syslog on/off As for windows environment, eventlog is used instead.
# Default: 0
#
# * `syslog_ident`
# Under what name to send logs to syslog.
# Default: pgbouncer
#
# * `syslog_facility`
# Under what facility to send logs to syslog. Possibilities: auth, authpriv,
# daemon, user, local0-7.
# Default: daemon
#
# * `log_connections`
# Log successful logins.
# Default: 1
#
# * `log_disconnections`
# Log disconnections with reasons.
# Default: 1
#
# * `log_pooler_errors`
# Log error messages pooler sends to clients.
# Default: 1
#
# * `stats_period`
# Period for writing aggregated stats into log.
# Default: 60
#
# * `verbose`
# Increase verbosity. Mirrors "-v" switch on command line. Using "-v -v" on
# command line is same as verbose=2 in config.
# Default: 0
#
#
# Console access control:
#
# * `admin_users`
# Comma-separated list of database users that are allowed to connect and run all
# commands on console. Ignored when  is any, in which case any username is
# allowed in as admin.
#
# Default: empty
#
# * `stats_users`
# Comma-separated list of database users that are allowed to connect and run
# read-only queries on console. Thats means all SHOW commands except SHOW
# FDS.
#
# Default: empty.
#
#
# Connection sanity checks, timeouts:
#
# * `server_reset_query`
# Query sent to server on connection release, before making it available to other
# clients. At that moment no transaction is in progress so it should not
# include ABORT or ROLLBACK. A good choice for Postgres 8.2 and below is:
#
#     server_reset_query = RESET ALL; SET SESSION AUTHORIZATION DEFAULT;
#
# for 8.3 and above, it's enough to do:
#
#     server_reset_query = DISCARD ALL;
#
# When transaction pooling is used, this should be empty, as clients should not
# use any session features. If client does use session features, then they will be
# broken as transaction pooling will not guarantee that next query will be run on
# same connection.
#
# Default: DISCARD ALL
#
# * `server_reset_query_always`
# Whether  should be run in all pooling modes. When this setting is off (default),
# the will be run only in pools that are in sessions-pooling mode.
# Connections in transaction-pooling mode should not have any need for reset query.
#
# Default: 0
#
# * `server_check_delay`
# How long to keep released connections available for immediate re-use, without
# running sanity-check queries on it. If 0 then the query is ran always.
#
# Default: 30.0
#
# * `server_check_query`
# Simple do-nothing query to check if the server connection is alive. If an empty
# string, then sanity checking is disabled.
#
# Default: SELECT 1;
#
# * `server_lifetime`
# The pooler will try to close server connections that have been connected longer
# than this. Setting it to 0 means the connection is to be used only once,
# then closed. [seconds]
#
# Default: 3600.0
#
# * `server_idle_timeout`
# If a server connection has been idle more than this many seconds it will be
# dropped. If 0 then timeout is disabled. [seconds]
#
# Default: 600.0
#
# * `server_connect_timeout`
# If connection and login won't finish in this amount of time, the connection will
# be closed. [seconds]
#
# Default: 15.0
#
# * `server_login_retry`
# If login failed, because of failure from connect() or authentication that pooler
# waits this much before retrying to connect. [seconds]
#
# Default: 15.0
#
# * `client_login_timeout`
# [seconds] If a client connects but does not manage to login in this amount of
# time, it will be disconnected. Mainly needed to avoid dead connections stalling
# SUSPEND and thus online restart.
#
# Default: 60.0
#
# * `autodb_idle_timeout`
# [seconds] If the automatically created (via "*") database pools have been unused
# this many seconds, they are freed. The negative aspect of that is that their
# statistics are also forgotten.
#
# Default: 3600.0
#
# * `dns_max_ttl`
# [seconds] How long the DNS lookups can be cached. If a DNS lookup returns
# several answers, pgbouncer will robin-between them in the meantime. Actual
# DNS TTL is ignored.
#
# Default: 15.0
#
# * `dns_nxdomain_ttl`
# [seconds] How long error and NXDOMAIN DNS lookups can be cached.
# Default: 15.0
#
# * `dns_zone_check_period`
# Period to check if zone serial has changed. PgBouncer can collect dns zones from
# hostnames (everything after first dot) and then periodically check if zone
# serial changes. If it notices changes, all hostnames under that zone are looked
# up again. If any host ip changes, it's connections are invalidated. Works only
# with UDNS backend.
# Default: 0.0 (disabled)
#
# Authors
# -------
#
# Carl P. Corliss <carl.corliss@finalsite.com>
#
# Copyright
# ---------
#
# Copyright 2015 Carl P. Corliss, unless otherwise noted.
#
# License
# -------
#
# Copyright (C) 2015, Carl P. Corliss <rabbitt@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class pgbouncer::config(
# Package Settings:
  $package_name              = undef,
  $package_ensure            = undef,

# Service Settings:
  $service_enable            = undef,
  $service_ensure            = undef,

# Responsibilities:
  $manage_package            = undef,
  $manage_service            = undef,
  $manage_dbconf             = undef,

# Paths
  $config_file               = undef,
  $db_config_file            = undef,
  $auth_file                 = undef,
  $auth_hba_file             = undef,
  $pidfile                   = undef,
  $logfile                   = undef,
  $unix_socket_dir           = undef,

# Generic Settings:
  $listen_addr               = undef,
  $listen_port               = undef,
  $unix_socket_mode          = undef,
  $runtime_user              = undef,
  $auth_type                 = undef,
  $auth_query                = undef,
  $pool_mode                 = undef,
  $max_client_conn           = undef,
  $default_pool_size         = undef,
  $min_pool_size             = undef,
  $reserve_pool_size         = undef,
  $reserve_pool_timeout      = undef,
  $max_db_connections        = undef,
  $max_user_connections      = undef,
  $server_round_robin        = undef,
  $ignore_startup_parameters = undef,
  $disable_pqexec            = undef,
  $application_name_add_host = undef,

# Log Settings:
  $syslog                    = undef,
  $syslog_ident              = undef,
  $syslog_facility           = undef,
  $log_connections           = undef,
  $log_disconnections        = undef,
  $log_pooler_errors         = undef,
  $stats_period              = undef,
  $verbose                   = undef,

# Console Access Control:
  $admin_users               = undef,
  $stats_users               = undef,

# Connection Sanity Checks / Timeouts:
  $server_reset_query        = undef,
  $server_reset_query_always = undef,
  $server_check_delay        = undef,
  $server_check_query        = undef,
  $server_lifetime           = undef,
  $server_idle_timeout       = undef,
  $server_connect_timeout    = undef,
  $server_login_retry        = undef,
  $client_login_timeout      = undef,
  $autodb_idle_timeout       = undef,
  $dns_max_ttl               = undef,
  $dns_nxdomain_ttl          = undef,
  $dns_zone_check_period     = undef,

  $raw_config                = {},
  $users                     = {},
  $databases                 = {},
) {

  assert_private()

  if ($manage_package) { validate_bool($manage_package) }
  if ($manage_service) { validate_bool($manage_service) }
  if ($manage_dbconf) { validate_bool($manage_dbconf) }

# Paths
  if ($config_file) { validate_absolute_path(dirname($config_file)) }
  if ($db_config_file) { validate_absolute_path(dirname($db_config_file)) }
  if ($auth_file) { validate_absolute_path(dirname($auth_file)) }
  if ($auth_hba_file) { validate_absolute_path($auth_hba_file) }
  if ($pidfile) { validate_absolute_path(dirname($pidfile)) }
  if ($logfile) { validate_absolute_path(dirname($logfile)) }
  if ($unix_socket_dir) { validate_absolute_path($unix_socket_dir) }

# Generic Settings:
  if ($listen_addr) {
    if (!is_ip_address($listen_addr) and $listen_addr != '*') {
      fail("expected valid IP address or '*' for listen_addr but found '${listen_addr}'")
    }
  }
  if ($listen_port) { validate_integer($listen_port, undef, 1025) }
  if ($unix_socket_mode) { validate_integer($unix_socket_mode) }
  if ($runtime_user) { validate_string($runtime_user) }
  if ($auth_type) {
    validate_re($auth_type, '^(?i:hba|cert|md5|plain|trust|any)$',
      "Invalid auth_type '${auth_type}'; expected one of hba, cert, md5, plain, trust or any.")
  }
  if ($auth_query) { validate_string($auth_query) }
  if ($pool_mode) {
    validate_re($pool_mode, '^(?i:session|transaction|statement)$',
      "Invalid pool_mode '${pool_mode}'; expected one of session, transaction or statement.")
  }
  if ($max_client_conn) { validate_integer($max_client_conn, undef, 0) }
  if ($default_pool_size) { validate_integer($default_pool_size, undef, 0) }
  if ($min_pool_size) { validate_integer($min_pool_size, undef, 0) }
  if ($reserve_pool_size) { validate_integer($reserve_pool_size, undef, 0) }
  if ($reserve_pool_timeout) { validate_numeric($reserve_pool_timeout, undef, 0.0) }
  if ($max_db_connections) { validate_integer($max_db_connections, undef, 0) }
  if ($max_user_connections) { validate_integer($max_user_connections, undef, 0) }
  if ($server_round_robin) { validate_bool($server_round_robin) }
  if ($ignore_startup_parameters) { validate_array($ignore_startup_parameters) }
  if ($disable_pqexec) { validate_bool($disable_pqexec) }

  if ($syslog) { validate_bool($syslog) }
  if ($syslog_ident) { validate_string($syslog_ident) }
  if ($syslog_facility) {
    validate_re($syslog_facility, '^(?i:auth(?:priv)?|daemon|user|local[0-7])$',
      "Invalid syslog_facility '${syslog_facility}'; expected one of auth, authpriv, daemon, user, local0-7.")
  }
  if ($log_connections) { validate_bool($log_connections) }
  if ($log_disconnections) { validate_bool($log_disconnections) }
  if ($log_pooler_errors) { validate_bool($log_pooler_errors) }
  if ($stats_period) { validate_integer($stats_period, undef, 1) }
  if ($verbose) { validate_integer($verbose, 2, 0) }

  if ($admin_users) { validate_array($admin_users) }
  if ($stats_users) { validate_array($stats_users) }

  if ($server_reset_query) { validate_string($server_reset_query) }
  if ($server_reset_query_always) { validate_bool($server_reset_query_always) }
  if ($server_check_delay) { validate_numeric($server_check_delay, undef, 0.0) }
  if ($server_check_query) { validate_string($server_check_query) }
  if ($server_lifetime) { validate_numeric($server_lifetime, undef, 0.0) }
  if ($server_idle_timeout) { validate_numeric($server_idle_timeout, undef, 0.0) }
  if ($server_connect_timeout) { validate_numeric($server_connect_timeout, undef, 0.0) }
  if ($server_login_retry) { validate_numeric($server_login_retry, undef, 0.0) }
  if ($client_login_timeout) { validate_numeric($client_login_timeout, undef, 0.0) }
  if ($autodb_idle_timeout) { validate_numeric($autodb_idle_timeout, undef, 0.0) }
  if ($dns_max_ttl) { validate_numeric($dns_max_ttl, undef, 0.0) }
  if ($dns_nxdomain_ttl) { validate_numeric($dns_nxdomain_ttl, undef, 0.0) }
  if ($dns_zone_check_period) { validate_numeric($dns_zone_check_period, undef, 0.0) }

  if ($raw_config) { validate_hash($raw_config) }
  if ($users) { validate_hash($users) }
  if ($databases) { validate_hash($databases) }

  $class_config_parameters = {
    'Paths' =>  {
      pidfile                   => $pidfile,
      logfile                   => $logfile,
      conffile                  => $config_file,
      auth_file                 => $auth_file,
      auth_hba_file             => $auth_hba_file,
      unix_socket_dir           => $unix_socket_dir,
    },
    'Generic Settings' =>  {
      listen_addr               => $listen_addr,
      listen_port               => $listen_port,
      unix_socket_mode          => $unix_socket_mode,
      runtime_user              => $runtime_user,
      auth_type                 => $auth_type,
      auth_query                => $auth_query,
      pool_mode                 => $pool_mode,
      max_client_conn           => $max_client_conn,
      default_pool_size         => $default_pool_size,
      min_pool_size             => $min_pool_size,
      reserve_pool_size         => $reserve_pool_size,
      reserve_pool_timeout      => $reserve_pool_timeout,
      max_db_connections        => $max_db_connections,
      max_user_connections      => $max_user_connections,
      server_round_robin        => bool2num($server_round_robin),
      ignore_startup_parameters => join($ignore_startup_parameters, ','),
      disable_pqexec            => bool2num($disable_pqexec),
      application_name_add_host => $application_name_add_host,
    },
    'Log Settings' =>  {
      syslog                    => bool2num($syslog),
      syslog_ident              => $syslog_ident,
      syslog_facility           => $syslog_facility,
      log_connections           => bool2num($log_connections),
      log_disconnections        => bool2num($log_disconnections),
      log_pooler_errors         => bool2num($log_pooler_errors),
      stats_period              => $stats_period,
      verbose                   => $verbose,
    },
    'Console Access Control' =>  {
      admin_users               => join($admin_users, ','),
      stats_users               => join($stats_users, ','),
    },
    'Connection Sanity Checks / Timeouts' =>  {
      server_reset_query        => $server_reset_query,
      server_reset_query_always => bool2num($server_reset_query_always),
      server_check_delay        => $server_check_delay,
      server_check_query        => $server_check_query,
      server_lifetime           => $server_lifetime,
      server_idle_timeout       => $server_idle_timeout,
      server_connect_timeout    => $server_connect_timeout,
      server_login_retry        => $server_login_retry,
      client_login_timeout      => $client_login_timeout,
      autodb_idle_timeout       => $autodb_idle_timeout,
      dns_max_ttl               => $dns_max_ttl,
      dns_nxdomain_ttl          => $dns_nxdomain_ttl,
      dns_zone_check_period     => $dns_zone_check_period,
    },
  }

  # build the pgbouncer parameter piece of the config file
  file { $config_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('pgbouncer/pgbouncer.ini.erb'),
  }

  concat { $auth_file:
    ensure => present,
  }

  concat::fragment {'pgb_user_header':
    target  => $auth_file,
    content => "; Puppet AUTO-GENERATED file; Modifications /WILL/ be overwritten.\n",
    order   => "01"
  }

  if (is_hash($users) and size($users) > 0) {
    create_resources('pgbouncer::user', $users)
  }

  concat::fragment { 'pgb_db_header':
    target  => $db_config_file,
    content => "; Puppet AUTO-GENERATED file; Modifications /WILL/ be overwritten.\n[databases]\n",
    order   => '01',
  }

  concat { $db_config_file:
    ensure  => present,
    replace => pick($manage_dbconf, true),
  }

  if (is_hash($databases) and size($databases) > 0) {
    create_resources('pgbouncer::database', $databases, {
      notify  => Class['pgbouncer::service']
    })
  }
}
