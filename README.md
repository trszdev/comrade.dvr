# ComradeDVR

### Install

```bash
brew bundle
brew bundle exec pre-commit install
brew bundle exec xcodegen
brew bundle exec frameit setup
```

### Test

```bash
brew bundle exec fastlane run_all_tests
```

### Make production build

```bash
brew bundle exec fastlane test_flight
```

### Deploy to .ipa to test flight

Generate an api key for appstore connect: https://docs.fastlane.tools/app-store-connect-api/

```bash
brew bundle exec fastlane run pilot api_key_path:<PATH_TO_API_KEY.json>
```

### Capture screenshots

```bash
brew bundle exec fastlane snapshot
brew bundle exec fastlane run frame_screenshots white:true path:./screenshots
```

