# hedgedoc-chart

A lightweight Helm chart for [HedgeDoc](https://github.com/hedgedoc/hedgedoc) that prioritizes
transparency and flexibility.

Linted with [`kube-score`](https://github.com/zegl/kube-score),
[`kube-linter`](https://github.com/stackrox/kube-linter)
and [`yamllint`](https://github.com/stackrox/kube-linter).
Tested with [`helm-unittest`](https://github.com/helm-unittest/helm-unittest).

## Design Philosophy

### Transparency and Flexibility over Abstraction and Convenience

This chart may diverge from some common chart conventions.
It favors transparency and flexibility over abstraction and convenience:

- **Values-Driven:** The goal is to provide a chart that can be understood just by looking at the values file.
  There should be no need to look into the templates to understand what the chart does and how it works.
- **Minimal Abstraction:** The chart avoids hidden logic and magic behavior as much as possible.
  A lot of what you see in the values file is what gets rendered in the templates.
- **Flexibility over Convenience:** The chart is designed to be flexible and understandable.
  But this comes at the cost of convenience.
  For example, if you want to use a config file instead of environment variables to configure your application,
  you can do so via editing the values file.
  But you'd have to make edits in multiple places. You'd have to set `.Values.configmap.enabled` to `true`,
  add the config to `.Values.configmap.data`
  and mount the ConfigMap by adapting `.Values.volumes` and `.Values.volumeMounts`.
  Another example, if you want to change the ports the application is using, you can do so. You'd have to set or adapt
  the environment variable that sets the port in `.Values.app.env`, and adapt `.Values.containerPorts` accordingly.

### No Dependencies

This chart does not bundle any databases (e.g., Postgres, Valkey) as a dependency.
While this may seem inconvenient, it keeps the chart lightweight, and ensures users actively design their setup.
Which database should be used? Is one already deployed? Should a new one be deployed? Is it deployed via helm chart or
operator? Which helm chart should be used? Is a managed database service used?
These are all questions that should be answered by the user, not the chart.

## Getting Started

Please read the charts [`README.md`](./chart/README.md) to get started.

## Contributing

Please check the [`CONTRIBUTING.md`](./CONTRIBUTING.md) to learn how to contribute.

## Development

### Installing dependencies

You can install all required dependencies via `Task` and `Homebrew`

```shell
brew install go-task
task install
```

If you'd like to use other tools,
you can find all dependencies and relevant commands in the [`taskfile.yaml`](./taskfile.yaml)

### Rendering the Helm Chart

```shell
task render
```

### Testing the Helm Chart

```shell
task test
```

### Running linters

```shell
task lint
```

### Generating documentation

```shell
task docs
```
