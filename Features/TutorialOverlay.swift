import SwiftUI

struct GestureTutorialOverlay: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Hoş Geldiniz")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                HStack(spacing: 40) {
                    VStack {
                        Image(systemName: "hand.point.right.fill")
                            .font(.largeTitle)
                        Text("Yapılanlar")
                            .font(.caption)
                    }
                    
                    VStack {
                        Image(systemName: "circle.circle")
                            .font(.largeTitle)
                        Text("Günlük")
                            .font(.caption)
                    }
                    
                    VStack {
                        Image(systemName: "hand.point.left.fill")
                            .font(.largeTitle)
                        Text("To-Do")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.white)
                
                Text("Ekranları değiştirmek için sola veya sağa kaydırın.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 32)
                
                Button("Anladım") {
                    withAnimation {
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
                .padding(.top, 16)
            }
        }
    }
}
