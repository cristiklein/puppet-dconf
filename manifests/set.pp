define dconf::set ($value,$user,$group) {
  include dconf

  debug "Dconf: set $name to $value for user $user and group $group"

  exec { "dconf set $name outside user session":
    command   => shellquote('dbus-launch', '--exit-with-session', 'dconf', 'write', $name, dconf_json($value)),
    path      => "/usr/bin",
    logoutput => "true",
    provider  => 'shell',
    require   => Package['dconf-tools'],
    user      => $user,
    group     => $group,
    onlyif    => [
      'test -z "$DBUS_SESSION_BUS_ADDRESS"',
      sprintf('test "$(dbus-launch --exit-with-session dconf read %s)" != %s', $name, shellquote(dconf_json($value))),
    ],
  }

  exec { "dconf set $name inside user session":
    command   => shellquote('dconf', 'write', $name, dconf_json($value)),
    path      => "/usr/bin:/bin",
    logoutput => "true",
    provider  => 'shell',
    require   => Package['dconf-tools'],
    user      => $user,
    group     => $group,
    onlyif    => [
      'test -n "$DBUS_SESSION_BUS_ADDRESS"',
      sprintf('test "$(dconf read %s)" != %s', $name, shellquote(dconf_json($value))),
    ],
  }
}
