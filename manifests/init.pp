class statsd(
  $ensure           = $statsd::params::ensure,
  $nodemoduledir    = $statsd::params::nodemoduledir,
  $graphiteserver   = $statsd::params::graphiteserver,
  $graphiteport     = $statsd::params::graphiteport,
  $backends         = $statsd::params::backends,
  $address          = $statsd::params::address,
  $listenport       = $statsd::params::listenport,
  $adminport        = $statsd::params::adminport,
  $flushinterval    = $statsd::params::flushinterval,
  $percentthreshold = $statsd::params::percentthreshold,
  $deleteidlestats  = $statsd::params::deleteidlestats,
  $dumpmessages     = $statsd::params::dumpmessages,
  $flushcounts      = $statsd::params::flushcounts,
  $configurereload  = $statsd::params::configurereload,
  $initscript       = $statsd::params::initscript,
  $statsjs          = $statsd::params::statsjs,
  $statsduser       = $statsd::params::statsduser,
  $statsdgroup      = $statsd::params::statsdgroup, 
  $provider         = $statsd::params::provider,
  $config           = $statsd::params::config,
  $nodemanage       = $statsd::params::nodemanage,
  $nodeversion      = $statsd::params::nodeversion,
) inherits statsd::params {

  if $nodemanage == true {
    class { '::nodejs': version => $nodeversion }
  }

  package { 'statsd':
    ensure   => $ensure,
    provider => $provider,
    notify  => Service['statsd'],
  }

  $configfile  = '/etc/statsd/localConfig${listenport}.js'
  $logfile     = '/var/log/statsd/statsd${listenport}.log'
  $initdfile   = '/etc/init.d/statsd${listenport}'
  $defaultfile = '/etc/default/statsd${listenport}'

  file { '/etc/statsd':
    ensure => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  } ->
  file { $configfile:
    content => template('statsd/localConfig.js.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['statsd'],
  }
  file { $initdfile:
    source  => $initscript,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['statsd'],
  }
  file {  $defaultfile:
    content => template('statsd/statsd-defaults.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['statsd'],
  }
  file { '/var/log/statsd':
    ensure => directory,
    owner  => $statsduser, 
    group  => $statsdgroup,
    mode   => '0770',
  }
  file { '/usr/local/sbin/statsd':
    source  => 'puppet:///modules/statsd/statsd-wrapper',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['statsd'],
  }

  service { 'statsd':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    pattern   => 'node .*stats.js',
    require   => File['/var/log/statsd'],
  }
}
