# Rebuild Source Area

This folder is reserved for the SwiftUI rebuild.

The existing UIKit files remain in place as legacy reference while the new app shell, domain models, and migration code are introduced incrementally. Files here should avoid depending directly on UIKit view controllers. If legacy behavior is needed, wrap it behind a small adapter or migration type.

The production bundle identifier must remain `io.orbit.orbit.prod` for App Store continuity and access to the existing app container.
