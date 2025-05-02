import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';

let lastTrackId = '';

Mpris.connect('player-changed', () => {
    const player = Mpris.players[0];
    if (!player) return;

    const { title, artist, album } = player.track;
    const trackId = `${title}-${artist}-${album}`;

    if (trackId === lastTrackId) return;
    lastTrackId = trackId;

    Notifications.add({
        appName: player.identity || 'Now Playing',
        summary: title || 'Unknown Title',
        body: artist || '',
        iconName: player.cover_path || 'media-playback-start-symbolic',
        urgency: 'normal',
        timeout: 5000,
    });
});
