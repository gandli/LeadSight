import SwiftUI

struct EmergencyButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
            action()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "sos.circle.fill")
                    .font(.system(size: 44))
                    .symbolEffect(.pulse)
                Text("紧急呼救")
                    .font(.headline)
                Text("一键上报位置并请求增援")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(
                        colors: [.red, Color(red: 0.8, green: 0, blue: 0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .shadow(color: .red.opacity(0.3), radius: 15, x: 0, y: 8)
            .accessibilityLabel("紧急呼救按钮")
            .accessibilityHint("双击一键上报当前位置并请求增援")
        }
        .padding(.horizontal)
    }
}

#Preview {
    EmergencyButton(action: {})
        .padding()
}
