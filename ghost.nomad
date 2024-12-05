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

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "ghost" {
      driver = "docker"

      config {
        image = "ghost:5-alpine"

        ports = ["ghost"]
        volumes = [
          "config/ghost-config.js:/var/lib/ghost/config.production.json",
          "local/ghost-content:/var/lib/ghost/content"
        ]
      }

      template {
        data = <<EOF
{
  "url": "http://blog.leandroaurelio.com",
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
        "NODE_ENV" = "development"
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "ghost"
        port = "ghost"
        tags = [ "urlprefix-blog.leandroaurelio.com/" ]

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    network {
      port "ghost" {
        to = 2368
      }
    }
  }

  group "db" {
    count = 1

    update {
      min_healthy_time = "3m"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "db" {
      driver = "docker"

      config {
        image = "mysql:8.0"
        ports = ["db"]
        volumes = [
          "local/mysql-data:/var/lib/mysql"
        ]
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "password"
        "MYSQL_DATABASE" = "ghostdata"
        "MYSQL_USER" = "ghostusr"
        "MYSQL_PASSWORD" = "password"
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

