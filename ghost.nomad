job "ghost-__NAMESPACE__" {
  datacenters = ["dc1"]
  type = "service"
  
  update {
    stagger = "30s"
    max_parallel = 2
  }
  
  namespace = "__NAMESPACE__"

  group "ghost-__NAMESPACE__" {

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

    task "ghost-__NAMESPACE__" {
      driver = "docker"

      config {
        image = "leandroaurelio/ghost:latest"

        ports        = ["ghost-__NAMESPACE__"]
        network_mode = "bridge"
        volumes      = [
          "config/ghost-config.js:/var/lib/ghost/config.production.json",
          "local/ghost-content:/var/lib/ghost/content"
        ]
      }

      template {
        data = <<EOF
{
  "url": "http://__SITE_URL__",
  "server": {
    "port": 2368,
    "host": "::"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "{{- range service "db-__NAMESPACE__" }}{{ .Address }}{{- end }}",
      "port": "{{- range service "db-__NAMESPACE__" }}{{ .Port }}{{- end }}",
      "user": "__MYSQL_USER__",
      "password": "__MYSQL_PASSWORD__",
      "database": "__MYSQL_DATABASE__"
    }
  },
  "mail": {
    "transport": "SMTP",
    "options": {
      "service": "service_provider",
      "host": "smtp.account_provider.com",
      "port": 465,
      "secure": true,
      "auth": {
        "user": "__USER_MAIL__",
        "pass": "__USER_PASSWORD__"
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
        name = "ghost-__NAMESPACE__"
        port = "ghost-__NAMESPACE__"
        tags = [ "urlprefix-__SITE_URL__/" ]

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    network {
      port "ghost-__NAMESPACE__" {
        static = __PORT__
        to     = 2368
      }
    }
  }

  group "db-__NAMESPACE__" {
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

    task "db-__NAMESPACE__" {
      driver = "docker"

      config {
        image   = "mysql:8.0"
        ports   = ["db-__NAMESPACE__"]
        volumes = [
          "local/mysql-data:/var/lib/mysql"
        ]
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "__MYSQL_ROOT_PASSWORD__"
        "MYSQL_DATABASE" = "__MYSQL_DATABASE__"
        "MYSQL_USER" = "__MYSQL_USER__"
        "MYSQL_PASSWORD" = "__MYSQL_PASSWORD__"
      }

      resources {
        cpu    = 1024
        memory = 1024
      }

      service {
        name = "db-__NAMESPACE__"
        port = "db-__NAMESPACE__"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    network {
      port "db-__NAMESPACE__" {
        to = 3306
      }
    }
  }
}
