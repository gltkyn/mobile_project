import SwiftUI

struct DiaryView: View {
    @State private var entryText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var statusMessage: String? = nil

    var body: some View {
        ZStack {
            // Arka plan: Boş alana dokunulduğunda klavyeyi kapatır
            Color(.systemBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    isInputFocused = false
                }
            
            VStack {
                Spacer()
                
                // Durum bildirimi (Kaydedildi vb.)
                if let statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                        .padding(.bottom, 8)
                }

                // Alt Metin BARI
                HStack(spacing: 12) {
                    TextField("Bugün ne oldu?", text: $entryText, axis: .vertical)
                        .lineLimit(1...5)
                        .focused($isInputFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(24)
                    
                    if !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: submitEntry) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.primary)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, isInputFocused ? 8 : 24)
            }
            .animation(.easeOut(duration: 0.25), value: isInputFocused)
        }
        .onAppear {
            LoggerService.shared.log("NAV: Opened Minimalist DiaryView")
        }
    }

    private func submitEntry() {
        let textToSave = entryText
        let saved = DiaryService.shared.saveEntry(text: textToSave)

        if saved {
            withAnimation {
                entryText = ""
                isInputFocused = false
                statusMessage = "Kaydedildi"
            }
            
            // 2 saniye sonra bildirim yazısını temizle
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    statusMessage = nil
                }
            }
        }
    }
}
