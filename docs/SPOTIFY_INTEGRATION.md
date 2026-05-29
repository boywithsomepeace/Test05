# Spotify Integration Notes

This project should keep Spotify separate from vehicle telemetry. Vehicle values must continue to come only from `VehicleDataManager` and from the properties listed in the official EV HMI Telemetry API PDF.

## Where Spotify Should Enter The App

Add the Spotify client on the backend side, beside the existing vehicle backend:

- `backend/SpotifyClient.h`
- `backend/SpotifyClient.cpp`
- Optional QML-facing manager: `backend/MediaDataManager.h` and `backend/MediaDataManager.cpp`

Expose media data to QML through a separate context property, for example `mediaData`. Do not add Spotify fields to `VehicleTelemetry`, because song title, artist, album art, playback state, and access tokens are not vehicle telemetry API properties.

The QML import path does not need a new module at first. Register the backend object in `main.cpp` the same way `vehicleData` is registered:

```cpp
engine.rootContext()->setContextProperty(QStringLiteral("mediaData"), &mediaData);
```

## Spotify API Pieces

Spotify playback normally needs these API areas:

- Authorization Code with PKCE for user login.
- `user-read-playback-state` to read current playback.
- `user-modify-playback-state` to play, pause, skip, or seek.
- `user-read-currently-playing` for the active track.

Keep these values outside QML:

- Client ID
- Redirect URI
- Access token
- Refresh token
- Token expiry time

Store tokens with `QSettings` or an OS credential store. QML should only see clean playback properties and invokable actions.

## Suggested Media Properties

These belong to a future `MediaDataManager`, not `VehicleDataManager`:

- `trackTitle`
- `artistName`
- `albumName`
- `albumArtUrl`
- `isPlaying`
- `progressMs`
- `durationMs`

If the UI needs any of these, add them to the media API. Do not add them to the EV telemetry API.

## QML Usage Pattern

The Music page should bind to `mediaData`, while the Home page should stay sparse and only show a small now-playing area if space allows.

Good separation:

```qml
Text { text: mediaData.trackTitle }
Text { text: vehicleData.speed }
```

Bad separation:

```qml
Text { text: vehicleData.trackTitle }
```

`vehicleData.trackTitle` is not in the official telemetry document and should not be invented.

## WSL Laptop Notes

This app is suitable for a 16 GB RAM laptop running from WSL or a Windows command prompt, but keep builds out of huge generated folders when possible.

Recommended workflow:

```bash
cmake -S . -B build
cmake --build build --parallel 4
```

If memory pressure appears, reduce parallelism:

```bash
cmake --build build --parallel 2
```

Qt Quick rendering should be tested on the Windows display side. If launching from WSL, make sure the Qt runtime can access the display server or use the existing Windows/MinGW build flow.
