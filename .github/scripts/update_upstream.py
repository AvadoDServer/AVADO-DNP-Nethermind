#!/usr/bin/env python3
"""
Script to automatically update Nethermind upstream version and package version.
Checks nethermindeth/nethermind for the latest release and updates configuration files accordingly.
"""

import json
import os
import sys
import urllib.request
from pathlib import Path


def get_latest_nethermind_release():
    """Fetch the latest release tag from nethermindeth/nethermind repository."""
    url = "https://api.github.com/repos/nethermindeth/nethermind/releases/latest"
    
    # Create request with proper headers
    request = urllib.request.Request(url)
    request.add_header('User-Agent', 'AVADO-DNP-Nethermind-Update-Bot')
    request.add_header('Accept', 'application/vnd.github.v3+json')
    
    # Add GitHub token if available (for authenticated requests)
    github_token = os.getenv('GITHUB_TOKEN')
    if github_token:
        request.add_header('Authorization', f'token {github_token}')
    
    try:
        with urllib.request.urlopen(request) as response:
            data = json.loads(response.read().decode())
            tag_name = data.get("tag_name", "")
            # Strip 'v' prefix if present
            version = tag_name.lstrip('v')
            return version
    except Exception as e:
        print(f"Error fetching latest release: {e}", file=sys.stderr)
        sys.exit(1)


def increment_patch_version(version):
    """Increment the patch version number (e.g., 0.0.62 -> 0.0.63)."""
    parts = version.split('.')
    if len(parts) != 3:
        print(f"Invalid version format: {version}", file=sys.stderr)
        sys.exit(1)
    
    parts[2] = str(int(parts[2]) + 1)
    return '.'.join(parts)


def update_dappnode_package(file_path, new_version, new_upstream):
    """Update version and upstream in dappnode_package-mainnet.json."""
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    old_version = data.get('version', '')
    old_upstream = data.get('upstream', '')
    
    data['version'] = new_version
    data['upstream'] = new_upstream
    
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')  # Add trailing newline
    
    return old_version, old_upstream


def update_docker_compose(file_path, new_version, new_upstream):
    """Update image tag and VERSION build argument in docker-compose-mainnet.yml."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    lines = content.split('\n')
    updated_lines = []
    
    for line in lines:
        # Update image tag
        if 'image:' in line and 'avado-dnp-nethermind.public.dappnode.eth:' in line:
            # Preserve indentation
            indent = line[:line.index('image:')]
            updated_lines.append(f"{indent}image: 'avado-dnp-nethermind.public.dappnode.eth:{new_version}'")
        # Update VERSION build argument
        elif 'VERSION:' in line:
            indent = line[:line.index('VERSION:')]
            updated_lines.append(f"{indent}VERSION: {new_upstream}")
        else:
            updated_lines.append(line)
    
    with open(file_path, 'w') as f:
        f.write('\n'.join(updated_lines))
        # Preserve trailing newline if original file had one
        if content.endswith('\n'):
            f.write('\n')


def main():
    # Get the repository root directory
    repo_root = Path(__file__).parent.parent.parent
    
    # File paths
    dappnode_package_path = repo_root / "build" / "dappnode_package-mainnet.json"
    docker_compose_path = repo_root / "build" / "docker-compose-mainnet.yml"
    
    print("Checking for Nethermind updates...")
    
    # Get latest Nethermind release
    latest_nethermind_version = get_latest_nethermind_release()
    print(f"Latest Nethermind version: {latest_nethermind_version}")
    
    # Read current upstream version
    with open(dappnode_package_path, 'r') as f:
        current_data = json.load(f)
    
    current_upstream = current_data.get('upstream', '')
    current_version = current_data.get('version', '')
    
    print(f"Current upstream version: {current_upstream}")
    print(f"Current package version: {current_version}")
    
    # Compare versions
    if latest_nethermind_version == current_upstream:
        print("Already up to date!")
        # Set GitHub Actions output
        if os.getenv('GITHUB_OUTPUT'):
            with open(os.getenv('GITHUB_OUTPUT'), 'a') as f:
                f.write(f"updated=false\n")
        # Also set as environment variables for the workflow
        if os.getenv('GITHUB_ENV'):
            with open(os.getenv('GITHUB_ENV'), 'a') as f:
                f.write(f"updated=false\n")
        sys.exit(0)
    
    print(f"New version available: {latest_nethermind_version}")
    
    # Increment package version
    new_package_version = increment_patch_version(current_version)
    print(f"New package version: {new_package_version}")
    
    # Update files
    print("Updating build/dappnode_package-mainnet.json...")
    update_dappnode_package(dappnode_package_path, new_package_version, latest_nethermind_version)
    
    print("Updating build/docker-compose-mainnet.yml...")
    update_docker_compose(docker_compose_path, new_package_version, latest_nethermind_version)
    
    print("Update complete!")
    
    # Set GitHub Actions output
    if os.getenv('GITHUB_OUTPUT'):
        with open(os.getenv('GITHUB_OUTPUT'), 'a') as f:
            f.write(f"updated=true\n")
            f.write(f"old_version={current_upstream}\n")
            f.write(f"new_version={latest_nethermind_version}\n")
            f.write(f"package_version={new_package_version}\n")
    
    # Also set as environment variables for the workflow
    if os.getenv('GITHUB_ENV'):
        with open(os.getenv('GITHUB_ENV'), 'a') as f:
            f.write(f"updated=true\n")
            f.write(f"old_version={current_upstream}\n")
            f.write(f"new_version={latest_nethermind_version}\n")
            f.write(f"package_version={new_package_version}\n")


if __name__ == "__main__":
    main()
