job "ghost" {
  datacenters = ["dc1"]
  type = "service"
  
  update {
    stagger      = "30s"
    max_parallel = 2
  }

  group "ghost" {
    count = 1

    update {
      canary = 1
    }

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
      "user": "__MYSQL_USER__",
      "password": "__MYSQL_PASSWORD__",
      "database": "__MYSQL_DATABASE__"
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

      template {
        data = <<EOT
#!/bin/sh
mkdir -p /local/ghost-content
cp -r /images/* /local/ghost-content/
EOT
        destination = "local/setup-content.sh"
        perms = "0755"
      }

      config {
        command = "/bin/sh"
        args = ["local/setup-content.sh"]
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "ghost"
        port = "ghost"
        tags = ["urlprefix-blog.leandroaurelio.com/"]

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
}
