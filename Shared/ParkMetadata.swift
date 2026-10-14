import AlarmKit

/// Zusatzdaten, die App und Widget-Extension gemeinsam nutzen.
/// Diese Datei gehört zu beiden Targets (siehe project.yml).
struct ParkMetadata: AlarmMetadata {
    var label: String
}
