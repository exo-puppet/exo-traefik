class traefik (
  $install_dir          = '/opt/traefik',
  $log_dir              = '/var/log/traefik',
  $web_console_binding  = '127.0.0.1:8080',
  $image_version        = 'v1.0.2',
  $log_level            = 'ERROR',
  $services_network     = 'reverse_proxy',
  $enable_https         = false,
  $force_https          = false,
  $ca_dir               = undef,
  $cert_file            = undef,
  $key_file             = undef,
  $http_binding         = '0.0.0.0:80',
  $https_binding        = '0.0.0.0:443',
  $debug                = false,
) {
  file { "${traefik::install_dir}" :
    ensure    => directory,
  } ->
  file { "${traefik::log_dir}" :
    ensure    => directory,
  } ->
  ########################
  ## Traefik configuration
  ########################
  file { "${install_dir}/traefik.toml" :
    ensure    => present,
    content   => template('traefik/traefik.toml.erb'),
    owner     => 'root',
    group     => 'root',
    mode      => '640',
    notify    => Docker_compose["${traefik::install_dir}/docker-compose.yml"],
  } ->
  ########################
  ## Docker compose file
  ########################
  file { "${install_dir}/docker-compose.yml":
    ensure    => present,
    content   => template('traefik/docker-compose.yml.erb'),
    owner     => 'root',
    group     => 'root',
    mode      => '640',
  }

  ###########################
  #  Launch the containers
  ###########################
  docker_compose { "${traefik::install_dir}/docker-compose.yml" :
    ensure  => 'present',
    require => [
      Class['docker::compose'],
      File["${traefik::install_dir}/docker-compose.yml"],
      File["${traefik::install_dir}/traefik.toml"]
    ],
  }

  ###########################
  #  LogRotate
  ###########################
  file { '/etc/logrotate.d/traefik.conf' :
    ensure => present,
    content => template('traefik/traefik.logrotate.erb'),
  }

}
