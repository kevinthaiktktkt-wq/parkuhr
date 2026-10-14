import SwiftUI

struct ContentView: View {
    @State private var store = ParkTimerStore()
    @AppStorage("minutes") private var minutes = 60
    @AppStorage("label") private var label = ""
    @State private var confirmCancel = false

    private let presets = [15, 30, 60, 90, 120, 180]

    var body: some View {
        NavigationStack {
            Group {
                if let end = store.endDate {
                    runningView(end: end)
                } else {
                    setupView
                }
            }
            .padding()
            .navigationTitle("Parkuhr")
        }
    }

    // MARK: - Timer einstellen

    private var setupView: some View {
        VStack(spacing: 24) {
            Text(format(minutes))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
                .padding(.top, 12)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(presets, id: \.self) { value in
                    Button {
                        minutes = value
                    } label: {
                        Text(format(value))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .tint(minutes == value ? .orange : .gray)
                }
            }

            Stepper(
                onIncrement: { minutes = min(720, (minutes / 5 + 1) * 5) },
                onDecrement: { minutes = max(1, ((minutes - 1) / 5) * 5) }
            ) {
                Text("Feinjustierung")
            }

            TextField("Parkplatz (optional)", text: $label)
                .textFieldStyle(.roundedBorder)

            Button {
                Task { await store.start(minutes: minutes, label: label) }
            } label: {
                Text("Timer starten")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            if let error = store.errorText {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Spacer()

            Button("1 Minute zum Testen") { minutes = 1 }
                .font(.footnote)
        }
    }

    // MARK: - Timer läuft

    private func runningView(end: Date) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 24) {
                Spacer()

                if end > context.date {
                    Text("Läuft ab um \(end.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(.secondary)

                    Text(timerInterval: context.date...end, countsDown: true)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)

                    if !label.isEmpty {
                        Label(label, systemImage: "parkingsign.circle.fill")
                            .foregroundStyle(.orange)
                    }

                    Spacer()

                    Button("Timer abbrechen", role: .destructive) {
                        confirmCancel = true
                    }
                    .buttonStyle(.bordered)
                    .confirmationDialog("Timer wirklich abbrechen?", isPresented: $confirmCancel) {
                        Button("Timer abbrechen", role: .destructive) { store.stopAndClear() }
                        Button("Weiterlaufen lassen", role: .cancel) {}
                    }
                } else {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.orange)
                    Text("Zeit abgelaufen!")
                        .font(.largeTitle.bold())

                    Spacer()

                    Button {
                        store.stopAndClear()
                    } label: {
                        Text("Alarm stoppen")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Hilfsfunktionen

    private func format(_ m: Int) -> String {
        if m >= 60 {
            let hours = m / 60
            let rest = m % 60
            return rest == 0 ? "\(hours) Std" : "\(hours) Std \(rest) Min"
        }
        return "\(m) Min"
    }
}
