# SwiftLint Setup

SwiftLint has been configured for this project. Follow these steps to complete the setup.

## Installation

### Option 1: Homebrew (Recommended)
```bash
brew install swiftlint
```

### Option 2: CocoaPods
If you're using CocoaPods, add to your `Podfile`:
```ruby
pod 'SwiftLint'
```

### Option 3: Swift Package Manager
Add SwiftLint as a package dependency in Xcode:
- File → Add Packages...
- Enter: `https://github.com/realm/SwiftLint.git`
- Select version: Latest Release

### Option 4: Download Binary
Download the latest release from: https://github.com/realm/SwiftLint/releases

## Configuration

The project includes a `.swiftlint.yml` configuration file in the root directory with the following settings:

- **Line length**: Warning at 120, Error at 150
- **Function body length**: Warning at 100, Error at 200
- **Type body length**: Warning at 300, Error at 500
- **File length**: Warning at 500, Error at 1000
- **Cyclomatic complexity**: Warning at 15, Error at 25

The configuration includes many opt-in rules for better code quality and consistency.

## Build Integration

A SwiftLint build phase has been added to the main target (`smartdustcollector`). It will:
- Run automatically before compilation during builds
- Show warnings/errors in Xcode's Issue Navigator
- Fail the build if errors are found (configurable)

## Running SwiftLint Manually

You can also run SwiftLint manually from the command line:

```bash
# Lint all files
swiftlint

# Auto-fix issues where possible
swiftlint --fix

# Lint specific files
swiftlint lint --path smartdustcollector/

# Generate HTML report
swiftlint lint --reporter html > swiftlint-report.html
```

## Disabling Rules

To disable specific rules for a file or line, use:

```swift
// swiftlint:disable rule_name
// Your code here
// swiftlint:enable rule_name

// Or for a single line:
let x = 0 // swiftlint:disable:this identifier_name
```

## Customization

Edit `.swiftlint.yml` to customize rules, thresholds, and included/excluded paths.

## Troubleshooting

### Sandbox Permission Errors

If you encounter sandbox permission errors like:
```
Sandbox: swiftlint deny(1) file-read-data /path/to/.swiftlint.yml
```

**Solution:**
1. Ensure SwiftLint is installed via Homebrew (recommended):
   ```bash
   brew install swiftlint
   ```
   
2. The build phase script has been updated to handle sandbox restrictions by:
   - Explicitly changing to the project root directory
   - Using absolute paths to SwiftLint binary
   - Explicitly specifying the config file path

3. If issues persist, try:
   - Reinstalling SwiftLint: `brew reinstall swiftlint`
   - Verifying SwiftLint is accessible: `which swiftlint`
   - Running SwiftLint manually from Terminal to verify it works outside Xcode

4. As an alternative, you can run SwiftLint manually or as a pre-commit hook instead of using the Xcode build phase.

For more information, visit: https://github.com/realm/SwiftLint
