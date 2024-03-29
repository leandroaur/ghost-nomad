job "ghost" {
  datacenters = ["dc1"]
  type = "service"
  
  update {
    stagger = "30s"
    max_parallel = 2
  }

  group "ghost" {

    update {
      canary = 1
    }
 
    count = 1

#use this volume mode if you have a local volume or nfs installed
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
        volume      = "ghost" #"ghost-csi"
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

    }
    network {
      port "ghost" {
        static = 2368
      }
    }
  }

  group "db" {
    count = 1

    update {
      min_healthy_time = "3m"
    }

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
