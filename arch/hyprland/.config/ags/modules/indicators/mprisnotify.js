import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Utils from 'resource:///com/github/Aylur/ags/utils.js';

let lastId = null;

Mpris.connect('player-added', (_, busName) => {
    const player = Mpris.getPlayer(busName);
    // Listen for metadata changes
    player.connect('notify::metadata', () => {
        const { 'xesam:title': title, 'xesam:artist': artist, 'mpris:artUrl': artUrl } = player.metadata || {};

        // Skip if no useful metadata
        if (!title || !artist) return;

        // Avoid duplicate notifications by checking last ID
        const currentId = `${title}-${artist}`;
        if (lastId === currentId) return;
        lastId = currentId;

        // Convert file:// URLs to absolute paths if needed
        let icon = artUrl;
        if (artUrl?.startsWith('file://'))
            icon = artUrl.replace('file://', '');

        Utils.notify(`${artist.join(', ')}`, title, icon);
    });
});
