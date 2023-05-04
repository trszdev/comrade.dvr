# ComradeDVR

### Install

```bash
brew bundle
pre-commit install
MINT_PATH=.mint mint bootstrap
./scripts/generate
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
