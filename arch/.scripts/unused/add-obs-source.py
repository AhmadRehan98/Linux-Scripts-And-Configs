#!/usr/bin/env python3

from obsws_python import ReqClient

# Configuration
host = "localhost"
port = 4455
password = "password"
source_name = "Screen Capture (PipeWire)"

try:
    client = ReqClient(host=host, port=port, password=password)
    response = client.get_input_settings(name=source_name)
    settings = response.input_settings
    print(f"DEBUG: Input settings for '{source_name}': {settings}")
except Exception as e:
    print(f"Error: {e}")
