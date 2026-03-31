# GitHub Actions CI/CD Guide

## Building APK Automatically

This project is configured with GitHub Actions to automatically build APK files on every push to `main` or `master` branch.

### Workflow Features:
- ✅ Automatic build on every push
- ✅ Java 17 setup
- ✅ Flutter 3.16.0
- ✅ Code analysis
- ✅ Running tests
- ✅ Building release APK
- ✅ Uploading artifacts
- ✅ Creating GitHub Releases

### How to trigger a build:

1. **Push to main branch:**
   ```bash
   git push origin main
   ```

2. **Manual trigger:**
   - Go to Actions tab in your GitHub repository
   - Select "Flutter Build APK" workflow
   - Click "Run workflow"

### Downloading the APK:

After successful build:
1. Go to Actions tab → Select the workflow run
2. Scroll down to "Artifacts" section
3. Download `release-apk` artifact

Or check the Releases page for automatic releases.

### Required Secrets (Optional):

For signed APKs, add these secrets to your repository:
- `KEYSTORE_BASE64`: Base64 encoded keystore file
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_ALIAS`: Key alias
- `KEY_PASSWORD`: Key password

### Workflow File Location:
`.github/workflows/flutter_build.yml`
