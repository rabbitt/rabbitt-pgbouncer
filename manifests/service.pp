# Class: pgbouncer::service
# ===========================
#
# Private class used by pgbouncer class to setup pgbouncer service.
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
class pgbouncer::service(
  $manage_service = $::pgbouncer::config::manage_service,
  $service_ensure = $::pgbouncer::config::service_ensure,
  $service_enable = $::pgbouncer::config::service_enable,
) {
  assert_private()

  validate_bool($manage_service)

  if ($manage_service) {
    if (!is_bool($service_ensure)) {
      validate_re($service_ensure, '^(?i:true|running|false|stopped)$',
        "Invalid service_ensure '${service_ensure}'; expected a boolean value, or one of running, stopped")
    }

    if (!is_bool($service_enable)) {
      validate_re($service_enable, '^(?i:true|false|manual|mask)$',
        "Invalid service_enable '${service_enable}'; expected a boolean value, or one of manual, mask")
    }

    service {'pgbouncer':
      ensure    => pick($service_ensure, 'running'),
      enable    => pick($service_enable, true),
      subscribe => [
        File[$::pgbouncer::config::config_file],
        File[$::pgbouncer::config::auth_file],
        File[$::pgbouncer::config::db_config_file],
      ],
    }
  }
}