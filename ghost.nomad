job "ghost" {
  datacenters = ["dc1"]
  type = "service"
  
  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "ghost" {
    task "wait-for-db" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image = "alpine"
        args = ["sh", "-c", "while ! nc -zv {{- range service \"db\" }}{{ .Address }}{{- end }} 3306; do sleep 1; done"]
      }
      resources {
        cpu = 500
        memory = 128
      }
    }
 
    count = 2

    volume "ghost" {
      type      = "host"
      read_only = false
      source    = "ghost"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "ghost" {
      driver = "docker"

      volume_mount {
        volume      = "ghost"
        destination = "/var/lib/ghost/content"
        read_only   = false
      }

      config {
        image = "ghost:5-alpine"

        ports = ["ghost"]
        volumes = [
        "config/ghost-config.js:/var/lib/ghost/config.production.json",
        ]
      }

      template {
        data = <<EOF
{
  "url": "https://leandroaurelio.com",
  "server": {
    "port": 2368,
    "host": "::"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "{{- range service "db" }}{{ .Address }}{{- end }}",
      "port": "{{- range service "db" }}{{ .Port }}{{- end }}",
      "user": "ghostusr",
      "password": "password",
      "database": "ghostdata"
    }
  },
  "mail": {
    "transport": "SMTP",
    "options": {
      "service": "service_provider",
      "host": "smtp.account.com",
      "port": 465,
      "secure": true,
      "auth": {
        "user": "user@mail.com",
        "pass": "password"
      }
    }    
  },
  "logging": {
    "transports": [
      "file",
      "stdout"
    ]
  },
  "process": "systemd",
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  }
}
        EOF
        destination = "config/ghost-config.js"

      }

      env = {
        "NODE_ENV" = "production"
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "ghost"
        port = "ghost"
        tags = [ "urlprefix-leandroaurelio.com/" ]

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

#      template {
#        data = <<EOH
#          {{ range $i, $e := service "db" }}
#          {{ if eq $i 0 }}{{ $e.Address }}{{ end }}
#          {{ end }}:{{ env "NOMAD_PORT_ghost" }}
#        EOH
#        destination = "secrets/db_address"
#      }
    }
    network {
      port "ghost" {
        static = 2368
      }
    }
  }

  group "db" {
    count = 1

    volume "mysql" {
      type      = "host"
      read_only = false
      source    = "mysql"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "db" {
      driver = "docker"

      volume_mount {
        volume      = "mysql"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "password"
        "MYSQL_DATABASE" = "ghostdata"
        "MYSQL_USER" = "ghostusr"
        "MYSQL_PASSWORD" = "password"
      }

      config {
        image = "mysql:8.0"

        ports = ["db"]
      }

      resources {
        cpu    = 1024
        memory = 1024
      }

      service {
        name = "db"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    network {
      port "db" {
        static = 3306
      }
    }
  }
}