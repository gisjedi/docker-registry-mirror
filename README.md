# Registry Mirror

Do you have a need for internal mirroring of a Docker Registry with minimal configuration headaches? This repo exists so that you can host "insecure" localhost proxies across a cluster of machines without dealing with Docker's hugely aggravating inability to set `--insecure-registry` on a per command basis.

There are 2 components:

* A registry image configured for mirroring
* A haProxy image configured to proxy the registry mirror

This setup exploits the Docker default to trust a localhost registry without any daemon configuration. We can deploy an internal registry mirror painlessly in a DC/OS cluster as follows:

registry-mirror marathon.json:

```
{
  "id": "/registry-mirror",
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "volumes": [],
    "docker": {
      "image": "gisjedi/registry-mirror"
    },
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 0,
        "labels": {
          "VIP_0": "/registry-mirror:5000"
        },
        "protocol": "tcp"
      }
    ]
  },
  "cpus": 0.2,
  "mem": 512,
  "requirePorts": true,
  "networks": [
    {
      "mode": "container/bridge"
    }
  ],
  "healthChecks": [
    {
      "portIndex": 0,
      "protocol": "MESOS_HTTP",
      "path": "/v2"
    }
  ],
  "fetch": [],
  "constraints": []
}
```

registry-proxy marathon.json:

```
{
  "id": "/registry-proxy",
  "instances": 19,
  "portDefinitions": [
    {
      "protocol": "tcp",
      "port": 5000
    }
  ],
  "container": {
    "type": "DOCKER",
    "volumes": [],
    "docker": {
      "image": "gisjedi/registry-proxy"
    }
  },
  "cpus": 0.1,
  "mem": 128,
  "requirePorts": true,
  "networks": [],
  "healthChecks": [
    {
      "portIndex": 0,
      "protocol": "MESOS_HTTP",
      "path": "/v2"
    }
  ],
  "fetch": [],
  "constraints": [
    [
      "hostname",
      "UNIQUE"
    ]
  ],
  "env": {
    "REGISTRY_HOST": "registry-mirror.marathon.l4lb.thisdcos.directory",
    "REGISTRY_PORT": "5000"
  }
}
```

Once this is deployed you can consume images found on Docker Hub by prefixing any standard image name with `localhost:5000/` and they will be cached in the registry mirror container.
