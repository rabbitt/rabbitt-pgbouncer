# Define: pgbouncer::user
# ===========================
#
# Private Define used for creating a specific user used for connecting to
# pgbouncer
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
define pgbouncer::user(
  $user          = undef,
  $password      = undef,
  $password_hash = undef,
) {
  assert_private()

  if ($user == undef) {
    $real_user = $name
  } else {
    $real_user = $user
  }

  if ($password and $password_hash) {
    fail('password and password_hash are mutually exclusive')
  } elsif ($password) {
    $real_password_hash = pgbouncer_password($real_user, $password)
  } else {
    validate_re($password_hash, '^(?i:(?:md5)?[a-f0-9]{32})$',
      "password_hash must be a valid MD5 string, optionally prefixed with 'md5'")

    if ($password_hash =~ /^(?i:md5)/) {
      $real_password_hash = $password_hash
    } else {
      $real_password_hash = "md5${password_hash}"
    }
  }

  $fragment_key = md5("pgb_user_entry_${real_user}")

  concat::fragment { $fragment_key:
    target  => $::pgbouncer::config::auth_file,
    content => "\"${real_user}\" \"${real_password_hash}\"\n",
    order   => '02',
  }
}
