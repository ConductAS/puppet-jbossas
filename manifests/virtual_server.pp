define jbossas::virtual_server($default_web_module = '',
$aliases = [],
$ensure = 'present')
{
  case $ensure {
    'present': {
      #        notice "JBoss Virtual Server $name: default_web_module=$default_web_module"
      if $default_web_module {
        $cli_args = inline_template('<% require "json" %>default-web-module=<%= default_web_module %>,alias=<%= aliases.to_json.gsub("\"", "\\\"") %>')
        } else {
        $cli_args = inline_template("<% require 'json' %>alias=<%= aliases.to_json %>")
        }
        notice "$jbossas::dir/bin/jboss-cli.sh -c --command='/subsystem=web/virtual-server=$name:add\\($cli_args\\)'"
        exec { "add jboss virtual-server $name":
          command => "${jbossas::dir}/bin/jboss-cli.sh -c --command=/subsystem=web/virtual-server=$name:add\\($cli_args\\)",
          user => 'jbossas', group => 'jbossas',
          logoutput => true,
          unless => "/bin/sh ${jbossas::dir}/bin/jboss-cli.sh -c /subsystem=web/virtual-server=$name:read-resource | grep success",
          notify => Service['jboss-as'],
          provider => 'posix'
        }
    }
    'absent': {
      exec { "remove jboss virtual-server $name":
        command => "${jbossas::dir}/bin/jboss-cli.sh -c '/subsystem=web/virtual-server=$name:remove()'",
        user => 'jbossas', group => 'jbossas',
        logoutput => true,
        onlyif => "/bin/sh ${jbossas::dir}/bin/jboss-cli.sh -c /subsystem=web/virtual-server=$name:read-resource | grep success",
        notify => Service['jboss-as'],
        provider => 'posix'
      }
    }
  }
}
