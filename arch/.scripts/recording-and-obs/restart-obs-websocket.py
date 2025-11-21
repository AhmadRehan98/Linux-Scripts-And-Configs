import base64
import hashlib
import json
import logging
logging.basicConfig(level=logging.DEBUG)
import websocket

LOG = logging.getLogger(__name__)

host = "localhost"
port = 4455 #or whatever port you use
password = "LooIYVDWGq912TpH"
id = 1

try:
    ws = websocket.WebSocket()
    url = "ws://{}:{}".format(host, port)
    ws.connect(url)
except:
    print("obs not running")
    exit()

def _build_auth_string(salt, challenge):
    secret = base64.b64encode(
        hashlib.sha256(
            (password + salt).encode('utf-8')
        ).digest()
    )
    auth = base64.b64encode(
        hashlib.sha256(
            secret + challenge.encode('utf-8')
        ).digest()
    ).decode('utf-8')
    return auth



def _auth():
    message = ws.recv()
    result = json.loads(message)
    server_version = result['d'].get('obsWebSocketVersion')
    auth = _build_auth_string(result['d']['authentication']['salt'], result['d']['authentication']['challenge'])

    payload = {
        "op": 1,
        "d": {
            "rpcVersion": 1,
            "authentication": auth,
            "eventSubscriptions": 1000
        }
    }
    ws.send(json.dumps(payload))
    message = ws.recv()
    # Message Identified...or so we assume...probably good to check if this is empty or not.
    result = json.loads(message)

_auth()

payload =  {"op":6,"d":{"requestType":"StopReplayBuffer","requestId":"StopReplayBuffer"}}
ws.send(json.dumps(payload))
message=ws.recv()
print(message)


payload =  {"op":6,"d":{"requestType":"CallVendorRequest","requestId":"kde-obs-shutdown","requestData":{"vendorName":"AdvancedSceneSwitcher","requestType":"AdvancedSceneSwitcherMessage","requestData":{"message":"kde-obs-shutdown"}}}}
ws.send(json.dumps(payload))
message=ws.recv()
print(message)

ws.close()

