# Class: pgbouncer::package
# ===========================
#
# Private class for pgbouncer package
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
class pgbouncer::package(
  $manage_package = $::pgbouncer::config::manage_package,
  $package_ensure = $::pgbouncer::config::package_ensure,
  $package_name   = $::pgbouncer::config::package_name,
) {
  assert_private()

  validate_bool($manage_package)

  if ($manage_package) {
    validate_string($package_ensure)
    validate_string($package_name)

    package { $package_name:
      ensure => pick($package_ensure, 'installed'),
    }
  }
}