class statsd::params {
  $ensure           = 'present'
  $nodemoduledir  = ''

  $graphiteserver   = 'localhost'
  $graphiteport     = '2003'
  $backends         = [ './backends/graphite' ]
  $address          = '0.0.0.0'
  $listenport       = '8125'
  $adminport        = '8126'
  $flushinterval    = '10000'
  $percentthreshold = ['90']
  $deleteidlestats  = false
  $dumpmessages     = false
  $flushcounts      = true
  $configreload     = true

  $initscript       = ''
  $statsjs          = ''

  $statsduser       = 'root'
  $statsgroup       = 'root'

  $provider         = 'npm'
  $config           = { }
  $nodemanage      = true
  $nodeversion     = 'present'

  $host             = '0.0.0.0'
  $proxyport        = 8125
  $nodes            = [ ]
  $udpversion       = 'udp4'
  $checkinterval    = 1000
  $cachesize        = 10000
  

  case $::osfamily {
    'RedHat', 'CentOS': {
      $initscript = 'puppet:///modules/statsd/statsd-init-rhel'
      if ! $nodemoduledir {
        $statsjs = '/usr/lib/node_modules/statsd/stats.js'
      }
      else {
        $statsjs = "${nodemoduledir}/statsd/stats.js"
      }
    }
    'Debian': {
      $initscript = 'puppet:///modules/statsd/statsd-init'
      if ! $nodemoduledir {
        case $provider {
          'apt': {
            $statsjs = '/usr/share/statsd/stats.js'
          }
          'npm': {
            $statsjs = '/usr/lib/node_modules/statsd/stats.js'
          }
          default: {
            fail('Unsupported provider')
          }
        }
      } 
      else {
        $statsjs = "${nodemoduledir}/statsd/stats.js"
      }
    }
    default: {
      fail('Unsupported OS Family')
    }
  }
}
