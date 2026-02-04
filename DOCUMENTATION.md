# ViewConfigure Documentation

This document explains how to build, deploy, and maintain the DocC documentation for ViewConfigure.

## Overview

ViewConfigure uses Swift-DocC (Documentation Compiler) to generate comprehensive documentation from inline comments and dedicated documentation files. The documentation is automatically built and deployed to GitHub Pages whenever changes are pushed to the main branch.

## Documentation Structure

```
ViewConfigure/Sources/ViewConfigure/ViewConfigure.docc/
├── ViewConfigure.md                    # Main landing page
├── GettingStarted.md                   # Installation and basic usage
├── Protocols.md                        # Core protocols documentation
├── Listeners.md                        # Built-in listeners reference
├── Styles.md                          # Built-in styles reference
├── Stores.md                          # State management guide
├── TypeErasedWrappers.md              # Type erasure explanation
├── CreatingCustomComponents.md         # Custom component tutorial
├── RegisterMacro.md                   # @Register macro guide
├── BestPractices.md                   # Architecture and performance
├── ConfigureMethod.md                 # Direct configuration method
└── BuildingRealWorldExample.md        # Complete tutorial
```

## Building Documentation

### Automated Deployment (GitHub Pages)

The documentation is automatically built and deployed using GitHub Actions:

1. **Trigger**: Pushes to `main` branch or changes to documentation files
2. **Build**: Uses `swift package generate-documentation` on macOS runner
3. **Deploy**: Publishes to GitHub Pages at `https://your-username.github.io/ViewConfigure/`

### Local Development

#### Quick Preview

For rapid iteration during documentation development:

```bash
./scripts/build-docs.sh --preview
```

This starts an interactive preview server that automatically rebuilds when files change.

#### Local Build

To build documentation for local viewing:

```bash
./scripts/build-docs.sh
```

Then open `ViewConfigure/docs/index.html` in your browser.

#### Static Hosting Build

To build documentation for static hosting (matching GitHub Pages):

```bash
./scripts/build-docs.sh --static
```

### Manual Build Commands

If you prefer to run commands directly:

```bash
cd ViewConfigure

# For local preview (interactive)
swift package --disable-sandbox preview-documentation --target ViewConfigure

# For local build
swift package --allow-writing-to-directory docs \
  generate-documentation --target ViewConfigure \
  --disable-indexing \
  --output-path docs

# For static hosting
swift package --allow-writing-to-directory docs \
  generate-documentation --target ViewConfigure \
  --disable-indexing \
  --transform-for-static-hosting \
  --hosting-base-path ViewConfigure \
  --output-path docs
```

## GitHub Actions Workflow

### Main Workflow Features

- **Caching**: Swift Package Manager dependencies are cached for faster builds
- **Multi-job**: Separate jobs for building and deploying
- **PR Checks**: Documentation builds are validated on pull requests without deployment
- **Permissions**: Minimal required permissions for security
- **Error Handling**: Clear error messages and build validation

### Workflow Configuration

The workflow is defined in `.github/workflows/docc-build-and-deploy.yml` and includes:

- **Build Job**: Runs on macOS-14 with Xcode 15.2
- **Deploy Job**: Deploys to GitHub Pages (main branch only)
- **Build Check**: Validates documentation on pull requests

### Environment Variables

No environment variables are required. The workflow uses:
- `GITHUB_TOKEN`: Automatically provided by GitHub
- Repository settings for Pages deployment

## GitHub Pages Setup

### Repository Configuration

1. Go to repository **Settings > Pages**
2. Set source to **GitHub Actions**
3. The workflow will handle the rest automatically

### Custom Domain (Optional)

To use a custom domain:

1. Add `CNAME` file to the repository root with your domain
2. Configure DNS settings with your domain provider
3. Update `--hosting-base-path` in the workflow if needed

## Documentation Guidelines

### Writing Documentation

1. **Use Markdown**: All documentation files use standard Markdown
2. **Code Examples**: Include practical, runnable code examples
3. **Cross-references**: Link related topics using `<doc:FileName>` syntax
4. **Images**: Place images in the `.docc` directory if needed
5. **Structure**: Follow the established topic hierarchy

### Code Documentation

#### Inline Documentation

```swift
/// A style that applies a gradient background to views.
///
/// Use this style to create visually appealing gradient backgrounds
/// that can enhance the visual hierarchy of your interface.
///
/// ```swift
/// Text("Hello")
///     .configured {
///         style(GradientStyle(colors: [.blue, .purple]))
///     }
/// ```
///
/// - Parameters:
///   - colors: The colors to use in the gradient
///   - startPoint: The starting point of the gradient
///   - endPoint: The ending point of the gradient
public struct GradientStyle: Style {
    // Implementation
}
```

#### Symbol Documentation

- Use `///` for documentation comments
- Include usage examples in code blocks
- Document all parameters and return values
- Explain when and how to use the API

### Topic Organization

Documentation is organized into topics in the main `ViewConfigure.md` file:

```markdown
## Topics

### Essential
- <doc:GettingStarted>
- <doc:Protocols>

### Configuration Methods
- <doc:ConfigureMethod>
- <doc:BuilderPattern>
```

## Troubleshooting

### Common Build Issues

1. **"No such target"**: Ensure you're in the ViewConfigure directory
2. **"Documentation build failed"**: Check for syntax errors in .md files
3. **"Module not found"**: Run `swift package resolve` first
4. **Permission errors**: Use `--allow-writing-to-directory` flag

### GitHub Actions Issues

1. **Build fails on push**: Check the Actions tab for detailed error logs
2. **Pages not updating**: Verify GitHub Pages is configured for GitHub Actions
3. **Cache issues**: Manually clear cache in Actions or update cache keys

### Local Preview Issues

1. **Preview not starting**: Ensure you have Xcode 14.3+ installed
2. **Changes not reflecting**: The preview server may need restart
3. **Port conflicts**: The preview server uses port 8000 by default

## Maintenance

### Regular Updates

1. **Dependencies**: Keep Swift and Xcode versions updated in workflows
2. **Actions**: Update action versions (checkout, upload-pages-artifact, etc.)
3. **Documentation**: Review and update content as the API evolves
4. **Examples**: Ensure code examples remain current and functional

### Content Review

- Review documentation quarterly for accuracy
- Update examples when API changes
- Add new documentation for new features
- Maintain consistency in writing style and formatting

### Performance Monitoring

- Monitor build times in GitHub Actions
- Optimize documentation structure if builds become slow
- Consider splitting large documentation files if needed

## Resources

- [Swift-DocC Documentation](https://swift.org/documentation/docc/)
- [DocC Tutorial](https://developer.apple.com/documentation/docc/documenting-a-swift-framework-or-package)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)

## Contributing

When contributing to documentation:

1. **Test Locally**: Always build and review documentation locally before submitting
2. **Follow Guidelines**: Adhere to the established writing and formatting guidelines
3. **Update Cross-references**: Ensure all links work correctly
4. **Include Examples**: Provide practical, working code examples
5. **Review PR Checks**: Ensure documentation builds successfully in PR checks

For questions or issues with documentation, please open an issue in the repository.
