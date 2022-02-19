# ComradeDVR

### Install

```bash
brew bundle
brew bundle exec pre-commit install
mint bootstrap
mint run swiftgen
mint run xcodegen
```

### Reveal secrets

```bash
git secret reveal
```

### Test

```bash
./scripts/test.sh
```

### Make and deploy production build

```bash
./scripts/build.sh
```
