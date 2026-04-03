#!/usr/bin/env python3

import re
import requests
import hashlib
import os
import sys

def update_poppler_pkgbuild(new_version):
    pkgbuild_path = 'mingw-w64-poppler/PKGBUILD'
    
    # Read the current PKGBUILD
    with open(pkgbuild_path, 'r') as file:
        content = file.read()
    
    # Update the version
    content = re.sub(r'pkgver=[\d.]+', f'pkgver={new_version}', content)
    
    # Update the source URL
    new_source_url = f'https://poppler.freedesktop.org/poppler-{new_version}.tar.xz'
    content = re.sub(r'source=\(".*?"\)', f'source=("{new_source_url}")', content)
    
    # Download the new source file
    response = requests.get(new_source_url)
    if response.status_code == 200:
        with open(f'poppler-{new_version}.tar.xz', 'wb') as file:
            file.write(response.content)
        
        # Calculate SHA256 sum
        sha256 = hashlib.sha256(response.content).hexdigest()
        
        # Update the SHA256 sum in PKGBUILD
        content = re.sub(r"sha256sums=\('.*'", f"sha256sums=('{sha256}'", content)
        
        # Write the updated PKGBUILD
        with open(pkgbuild_path, 'w') as file:
            file.write(content)
        
        print(f"PKGBUILD updated with version {new_version} and new SHA256 sum.")
    else:
        print(f"Failed to download the new source file. HTTP status code: {response.status_code}")


def increment_pkgrel(pkgbuild_path):
    with open(pkgbuild_path, 'r') as file:
        content = file.read()

    # Find the current pkgrel value
    match = re.search(r'pkgrel=(\d+)', content)
    if match:
        current_pkgrel = int(match.group(1))
        new_pkgrel = current_pkgrel + 1
        
        # Replace the old pkgrel with the new one
        updated_content = re.sub(r'pkgrel=\d+', f'pkgrel={new_pkgrel}', content)
        
        with open(pkgbuild_path, 'w') as file:
            file.write(updated_content)
        
        print(f"Updated {pkgbuild_path}: pkgrel {current_pkgrel} -> {new_pkgrel}")
    else:
        print(f"Could not find pkgrel in {pkgbuild_path}")

def update_pkgrels(folder_list):
    for folder in folder_list:
        pkgbuild_path = os.path.join(folder, 'PKGBUILD')
        if os.path.exists(pkgbuild_path):
            increment_pkgrel(pkgbuild_path)
        else:
            print(f"PKGBUILD not found in {folder}")

# Usage
args= sys.argv[1:]
if len(args) == 1:
    new_version = args[0]
else:
    new_version = "24.11.0"  # Replace with the desired new version
update_poppler_pkgbuild(new_version)
# force rebuild of the package with dependencies to poppler
# update_pkgrels(['mingw-w64-pdf2djvu','mingw-w64-gdcm','mingw-w64-dia','mingw-w64-inkscape','mingw-w64-gdal'])