# VSCode Devcontainer Configuration

## Rootless Docker

`.devcontainer.json` に `remoteEnv` の設定が必要。

```json
{
  "name": "My Workspace",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "remoteEnv": {
    "DOCKER_HOST": "unix:///run/user/${UID}/docker.sock"
  },
  "mounts": [
    "source=/run/user/1000/docker.sock,target=/run/user/1000/docker.sock,type=bind"
  ]
}
```
