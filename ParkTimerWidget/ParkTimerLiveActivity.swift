import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

@main
struct ParkTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        ParkTimerLiveActivity()
    }
}

/// Zeigt den Countdown in der Dynamic Island, auf dem Sperrbildschirm und im StandBy.
/// Das Klingeln selbst übernimmt das System (AlarmKit).
struct ParkTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<ParkMetadata>.self) { context in
            // Sperrbildschirm / Banner
            HStack(spacing: 14) {
                Image(systemName: "parkingsign.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title(for: context.attributes.metadata))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    CountdownText(state: context.state)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                Spacer()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "parkingsign.circle.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(title(for: context.attributes.metadata))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "parkingsign.circle.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                CountdownText(state: context.state)
                    .frame(maxWidth: 56)
            } minimal: {
                Image(systemName: "parkingsign.circle.fill")
                    .foregroundStyle(.orange)
            }
        }
    }

    private func title(for metadata: ParkMetadata?) -> String {
        if let label = metadata?.label, !label.isEmpty {
            return "Parkuhr – \(label)"
        }
        return "Parkuhr"
    }
}

/// Laufender Countdown als Text, den das System sekündlich selbst aktualisiert.
struct CountdownText: View {
    let state: AlarmPresentationState

    var body: some View {
        if case let .countdown(countdown) = state.mode {
            let now = Date.now
            Text(timerInterval: now...max(countdown.fireDate, now), countsDown: true)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        } else {
            Image(systemName: "bell.fill")
                .foregroundStyle(.orange)
        }
    }
}
