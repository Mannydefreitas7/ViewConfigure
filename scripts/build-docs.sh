#!/bin/bash

# Build DocC Documentation Script
# This script builds the ViewConfigure DocC documentation locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "ViewConfigure/Package.swift" ]; then
    print_error "Package.swift not found in ViewConfigure directory."
    print_error "Please run this script from the repository root directory."
    exit 1
fi

print_status "Building ViewConfigure DocC Documentation..."

# Change to ViewConfigure directory
cd ViewConfigure

# Clean previous builds if they exist
if [ -d "docs" ]; then
    print_status "Cleaning previous documentation build..."
    rm -rf docs
fi

if [ -d ".build" ]; then
    print_status "Cleaning previous package build..."
    rm -rf .build
fi

# Resolve dependencies
print_status "Resolving Swift Package dependencies..."
swift package resolve

# Build the documentation
print_status "Generating DocC documentation..."

# For local preview (development)
if [ "$1" = "--preview" ] || [ "$1" = "-p" ]; then
    print_status "Building documentation for local preview..."
    swift package --disable-sandbox preview-documentation --target ViewConfigure
    exit 0
fi

# For static hosting (GitHub Pages)
if [ "$1" = "--static" ] || [ "$1" = "-s" ]; then
    print_status "Building documentation for static hosting..."
    swift package --allow-writing-to-directory docs \
        generate-documentation --target ViewConfigure \
        --disable-indexing \
        --transform-for-static-hosting \
        --hosting-base-path ViewConfigure \
        --output-path docs
else
    # Default: build for local viewing
    print_status "Building documentation for local viewing..."
    swift package --allow-writing-to-directory docs \
        generate-documentation --target ViewConfigure \
        --disable-indexing \
        --output-path docs
fi

# Check if documentation was built successfully
if [ -d "docs" ]; then
    print_success "Documentation built successfully!"
    print_status "Output directory: $(pwd)/docs"

    # Count generated files
    html_files=$(find docs -name "*.html" 2>/dev/null | wc -l)
    print_status "Generated $html_files HTML files"

    if [ "$1" = "--static" ] || [ "$1" = "-s" ]; then
        print_success "Documentation is ready for static hosting (GitHub Pages)"
        print_status "You can test locally by serving the docs directory with any HTTP server"
        print_status "Example: python3 -m http.server 8000 --directory docs"
    else
        print_success "Documentation is ready for local viewing"
        print_status "Open docs/index.html in your browser to view the documentation"
    fi

    # Show some example files that were generated
    print_status "Sample generated files:"
    find docs -name "*.html" | head -5 | while read file; do
        echo "  - $file"
    done

else
    print_error "Documentation build failed!"
    exit 1
fi

# Return to original directory
cd ..

print_success "DocC documentation build completed!"

# Usage instructions
echo ""
echo "Usage:"
echo "  $0                  Build documentation for local viewing"
echo "  $0 --static (-s)    Build documentation for static hosting (GitHub Pages)"
echo "  $0 --preview (-p)   Start interactive preview server"
echo ""
