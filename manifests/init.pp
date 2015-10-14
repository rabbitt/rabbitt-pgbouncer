# Class: pgbouncer
# ===========================
#
# Manages PGBouncer service and configuration.
#
# Parameters
# ----------
#
# * `config`
# Specify one or more valid pgbouncer config options as a hash
#
# * `users`
# Specify one or more authentication users as a hash
#
# * `databases`
# Specify one or more database mappings as a hash
#
# Variables
# ----------
#
# No external dependencies
#
# Examples
# --------
#
# @example
#   class { pgbouncer:
#     config => {
#       listen_addr => "${::ipaddress}",
#       listen_port => 5433,
#       max_client_conn => 100.
#     },
#     databases => {
#       example  => { host: 'db01.example.com' },
#       postgres => { host: 'db01.example.com', user => postgres },
#     },
#     users => {
#       'joeybutta' => { password_hash => 'md5b261f89f8c36dbefb1da73f300663594'}
#     }
#   }
#
# Hiera example
# -------------
#
# @example
#   pgbouncer::config::listen_addr: '%{ipaddress}'
#   pgbouncer::config::listen_port: 5433
#   pgbouncer::config::max_client_conn: 100
#   pgbouncer::databases:
#     example: { host: 'db01.example.com' }
#     postgres: { host: 'db01.example.com', user: 'postgres' }
#   pgbouncer::users:
#     joeybutta: { password_hash: 'md5b261f89f8c36dbefb1da73f300663594' }
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
class pgbouncer (
  $config    = {},
  $users     = {},
  $databases = {},
) {
  anchor{'pgbouncer::begin': } ->

  class { 'pgbouncer::package':
    manage_package => pick($config['manage_package'], hiera('pgbouncer::config::manage_package')),
    package_name   => pick($config['package_name'], hiera('pgbouncer::config::package_name')),
    package_ensure => pick($config['package_ensure'], hiera('pgbouncer::config::package_ensure')),
  }

  create_resources('class', {
    'pgbouncer::config' => deep_merge({
      require => Class['pgbouncer::package'],
      before  => Class['pgbouncer::service'],
      notify  => Class['pgbouncer::service'],
    }, deep_merge($config, { databases => $databases, users => $users }))
  })

  class { 'pgbouncer::service':
    manage_service => pick($config['manage_service'], hiera('pgbouncer::config::manage_service')),
    service_enable => pick($config['service_enable'], hiera('pgbouncer::config::service_enable')),
    service_ensure => pick($config['service_ensure'], hiera('pgbouncer::config::service_ensure')),
  } ->

  anchor{ 'pgbouncer::end': }
}
