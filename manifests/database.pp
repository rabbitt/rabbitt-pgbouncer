# Define: pgbouncer::database
# ===========================
#
# Private define for managing database entries
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
define pgbouncer::database(
  $client_dbname      = undef,
  $server_dbname      = undef,
  $host               = undef,
  $port               = undef,
  $user               = undef,
  $password           = undef,
  $auth_user          = undef,
  $pool_size          = undef,
  $connect_query      = undef,
  $pool_mode          = undef,
  $max_db_connections = undef,
  $client_encoding    = undef,
  $datestyle          = undef,
  $timezone           = undef,
) {
  assert_private()

  if ($client_dbname == undef) {
    $real_client_db = $name
  } else {
    $real_client_db = $client_dbname
  }

  if ($server_dbname == undef) {
    $real_server_db = $real_client_db
  } else {
    $real_server_db = $server_dbname
  }

  # required parameters
  validate_string($real_client_db)
  validate_re($real_client_db, '^[a-z0-9_]+$',
    "Invalid database name '${real_client_db}'; expected value to match /^[a-z0-9_]+$/")

  validate_string($real_server_db)
  validate_re($real_server_db, '^[a-z0-9_]+$',
    "Invalid database name '${real_server_db}'; expected value to match /^[a-z0-9_]+$/")

  validate_string($host)
  validate_re($host, '^(([a-z0-9-]+\.)+[a-z0-9]+|(\d{1,3}\.){3}\.\d{1,3})$',
    "Invalid host '${host}'; expected a value that looks like a hostname or ip.")

  # optional parameters
  if ($port) { validate_integer($port, 65535, 1025) }
  if ($user) { validate_string($user) }
  if ($password) { validate_string($password) }
  if ($auth_user) { validate_string($auth_user) }
  if ($pool_size) { validate_integer($pool_size, undef, 1) }
  if ($connect_query) { validate_string($connect_query) }
  if ($pool_mode) {
    validate_string($pool_mode)
    validate_re($pool_mode, '^(statement|transaction|session)',
      "Invalid pool_mode '${pool_mode}'; expected one of statement, transaction or sesssion.")
  }
  if ($max_db_connections) { validate_integer($max_db_connections, undef, 1) }
  if ($client_encoding) { validate_string($client_encoding) }
  if ($datestyle) { validate_string($datestyle) }
  if ($timezone) { validate_string($timezone) }

  $database_connect_options = {
    dbname             => $real_server_db,
    host               => $host,
    port               => $port,
    user               => $user,
    password           => $password,
    auth_user          => $auth_user,
    pool_size          => $pool_size,
    connect_query      => $connect_query,
    pool_mode          => $pool_mode,
    max_db_connections => $max_db_connections,
    client_encoding    => $client_encoding,
    datestyle          => $datestyle,
    timezone           => $timezone,
  }

  $key_components = reject(
    ['pgb_db_entry', $real_client_db, $real_server_db, $user, $host, $port],
    '^(?i:\s*|undef(ined)?)$')

  $fragment_key = md5(join($key_components, '_'))

  concat::fragment { $fragment_key:
    target  => $::pgbouncer::config::db_config_file,
    content => template('pgbouncer/databases.ini-entry.erb'),
    order   => '02',
  }
}
