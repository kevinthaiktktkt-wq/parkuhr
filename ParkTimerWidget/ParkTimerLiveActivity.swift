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
    private let accent = Color.orange

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<ParkMetadata>.self) { context in
            // Sperrbildschirm / Banner
            HStack(spacing: 14) {
                Image(systemName: "parkingsign.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title(for: context.attributes.metadata))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                    CountdownText(state: context.state)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.65))
            .activitySystemActionForegroundColor(accent)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "parkingsign.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(title(for: context.attributes.metadata))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }
            } compactLeading: {
                Image(systemName: "parkingsign.circle.fill")
                    .foregroundStyle(accent)
            } compactTrailing: {
                CountdownText(state: context.state)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: 60)
            } minimal: {
                Image(systemName: "parkingsign.circle.fill")
                    .foregroundStyle(accent)
            }
            // Farbige Umrandung der Insel, wie bei EasyPark
            .keylineTint(accent)
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
