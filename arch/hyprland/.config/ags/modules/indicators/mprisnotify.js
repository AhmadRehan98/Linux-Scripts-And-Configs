import { notify } from 'resource:///com/github/Aylur/ags/utils.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Utils from 'resource:///com/github/Aylur/ags/utils.js';

const activePlayers = new Set();
let lastId = null;
let currentMedia = null;

let lastTrackId = null;

Mpris.connect('player-changed', (player) => {
    if (!player) return;

    const { 'xesam:title': title, 'xesam:artist': artist, 'mpris:artUrl': artUrl } = player.metadata || {};
    const trackId = player.trackId || player.identity; // Use a unique identifier

    if (trackId && trackId !== lastTrackId) {
        notify({
            summary: `${artist?.join(', ') || 'Unknown Artist'} - ${title || 'Unknown Title'}`,
               body: 'Now Playing',
               icon: artUrl || 'media-playback-start',
               appName: 'AGS Music'
        });
        lastTrackId = trackId;
    }
});
