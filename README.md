# GitHub Actions Runner in Docker

Allows hosting [GitHub Actions Runner](https://github.com/actions/runner) in Docker containers

Both organisation-wide and repository-specific registrations of runners is supported.

## Configuration

To allow automatic registration of the agent, [Personal Access Token (PAT)](https://github.com/settings/tokens)
has to be created. Following scopes are required to be able to register agents:

- repository-specific agents: `repo`
- organisation-wide agents: `repo` and `admin:org`

### Environment Variables

In order to configure the runner, there are multiple environment variables available:

#### Generic
- `GITHUB_PAT` **(required)** Personal Access Token with the permissions described earlier
- `RUNNER_LABELS` *(optional)* Comma-separated list of labels to be assigned to an agent

#### Organisation-wide runners
- `GITHUB_ORG` **(required)** Name of the organisation

#### Repository-specific runners
- `GITHUB_OWNER` **(required)** Owner of the repository
- `GITHUB_REPOSITORY` **(required)** Repository name

## Use in Kubernetes

Below is an example deployment that can be used to run GitHub Actions Runners in Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: github-actions-runner
  labels:
    app: github-actions-runner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: github-actions-runner
  template:
    metadata:
      labels:
        app: github-actions-runner
    spec:
      containers:
      - name: runner
        image: vv12/github-actions-runner
        env:
        - name: GITHUB_OWNER
          value: vv12
        - name: GITHUB_REPOSITORY
          value: docker-github-actions-runner
        - name: GITHUB_PAT
          valueFrom:
            secretKeyRef:
              name: github
              key: pat
```

Do not forget to create a secret with your PAT:
```bash
kubectl create secret generic github --from-literal=pat=YOUR_PAT_HERE
```