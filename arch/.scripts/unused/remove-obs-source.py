#!/usr/bin/env python3

import subprocess
import json
import sys
from time import sleep
from obsws_python import ReqClient
from obsws_python.error import OBSSDKError

# Configuration
host = "localhost"
port = 4455
password = "password"
scene_name = "Scene"
# source_name = "Screen Capture (PipeWire)"
source_name = "Specific App"
input_kind = "pipewire-screen-capture-source"


def run_obs_cli_command():
    """Run obs-cli command to get scene item list."""
    cmd = [
        "obs-cli",
        "--host",
        host,
        "--port",
        str(port),
        "--password",
        password,
        "-j",  # JSON output
        "item",
        "list",
        "--scene",
        scene_name,
    ]

    try:
        result = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True
        )
        response = json.loads(result.stdout)
        # print(f"DEBUG: obs-cli response: {response}")  # Debug output
        return response
    except FileNotFoundError:
        print("Error: 'obs-cli' is not installed or not found in PATH.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to get scene item list: {e.stderr.strip()}")
        sys.exit(1)
    except json.JSONDecodeError:
        print("Error: Invalid JSON response from obs-cli.")
        sys.exit(1)


def find_scene_item_id(items):
    """Find the scene item ID for the given source name."""
    if not isinstance(items, list):
        print(f"Error: Expected a list of scene items, got: {type(items)}")
        sys.exit(1)

    target_item = next(
        (item for item in items if item.get("sourceName") == source_name), None
    )
    if not target_item:
        print(f"Error: Source '{source_name}' not found in scene '{scene_name}'.")
        sys.exit(1)
    return target_item["sceneItemId"]


def remove_scene_item(client: ReqClient, scene_item_id):
    """Remove the scene item using obsws-python."""
    try:
        settings_response = client.get_input_settings(name=source_name)
        print(
            f"DEBUG: Source settings before deletion: {settings_response.input_settings}",
        )
        client.remove_scene_item(scene_name, scene_item_id)
        print(
            f"✅ Removed '{source_name}' (ID {scene_item_id}) from scene '{scene_name}'."
        )
        return settings_response.input_settings

    except OBSSDKError as e:
        print(f"Error: Failed to remove scene item: {e}")
        sys.exit(1)
    except AttributeError as e:
        print(f"Error: Method not found in obsws-python: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: Unexpected error while connecting to OBS WebSocket: {e}")
        sys.exit(1)


def add_pipewire_source(client: ReqClient, input_settings={}):
    """Add a PipeWire screen capture source to the scene."""
    # Try settings to capture the primary screen

    print(f"DEBUG: Using input settings: {input_settings}")

    try:
        response = client.create_input(
            sceneName=scene_name,
            inputName=source_name,
            inputKind=input_kind,
            inputSettings=input_settings,
            sceneItemEnabled=True,
        )

        scene_item_id = response.scene_item_id
        print(f"DEBUG: Created scene item with ID {scene_item_id}")

        # Verify the source's settings after creation
        settings_response = client.get_input_settings(name=source_name)
        print(
            f"DEBUG: Source settings after creation: {settings_response.input_settings}",
        )

        return scene_item_id
    except OBSSDKError as e:
        print(f"Error creating source: {e}")
        raise


def run_command(command):
    """Execute a shell command and return its success status."""
    try:
        result = subprocess.run(
            command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True,
        )
        print(f"DEBUG: Command '{command}' succeeded: {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error: Command '{command}' failed: {e.stderr.strip()}")
        return False
    except Exception as e:
        print(f"Error: Unexpected error running '{command}': {e}")
        return False


def restart_pipewire_services():
    """Restart PipeWire and related services."""
    services = ["pipewire", "pipewire-pulse", "wireplumber", "xdg-desktop-portal-kde"]
    print("Restarting PipeWire services...")
    success = True
    for service in services:
        command = f"systemctl --user restart {service}"
        print(f"Executing: {command}")
        if not run_command(command):
            success = False
        # Brief delay to ensure service restarts
        sleep(1)
    return success


def main():
    # Step 1: Get scene item list using obs-cli
    client = ReqClient(host=host, port=port, password=password)

    print(f"Fetching scene items for scene '{scene_name}'...")
    response = run_obs_cli_command()

    # Handle response as a list directly
    items = response if isinstance(response, list) else response.get("sceneItems", [])

    if not items:
        print(f"Error: No items found in scene '{scene_name}'.")
        sys.exit(1)

    # Step 2: Find the scene item ID
    print(f"Looking for source '{source_name}'...")
    scene_item_id = find_scene_item_id(items)

    # Step 3: Remove the scene item
    print(f"Removing source '{source_name}' (ID {scene_item_id})...")
    input_settings = remove_scene_item(client, scene_item_id)

    sleep(1)

    # Restart PipeWire services
    # if not restart_pipewire_services():
    #     print(
    #         "Warning: Some PipeWire services failed to restart. Proceeding with source creation."
    #     )

    sleep(3)

    # Step 4: Add the scene item back
    scene_item_id = add_pipewire_source(client, input_settings)
    print(f"✅ Added '{source_name}' (ID {scene_item_id}) to scene '{scene_name}'.")


if __name__ == "__main__":
    main()
