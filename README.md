# NoSnooze

An alarm clock you can't sleep through. When it rings, the only way to end it
is to complete a mission — push-ups, a photo, reading a line aloud, or a quick
puzzle. Every morning you win extends your streak.

Requires iOS 26 or later.

## Building

Every push to `main` is built by GitHub Actions: the Xcode project is generated
from `project.yml` with XcodeGen, unit tests run on the iOS simulator, and an
unsigned `NoSnooze.ipa` is uploaded as the `NoSnooze-ipa` artifact.

To install on a device, download the artifact and sideload it with a signing
tool such as Sideloadly using your Apple ID.
