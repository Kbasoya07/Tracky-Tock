import SwiftUI

/// Particle model for lightweight celebration confetti bursts.
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double
}

/// Particle celebration overlay rendering an animated confetti shower.
public struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating: Bool = false
    
    private let colors: [Color] = [.red, .yellow, .green, .blue, .orange, .purple, .pink]
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 1.5)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
                startAnimation(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        var newParticles: [ConfettiParticle] = []
        for _ in 0..<35 {
            let startX = CGFloat.random(in: size.width * 0.1...size.width * 0.9)
            let startY = CGFloat.random(in: -20...20)
            let particle = ConfettiParticle(
                x: startX,
                y: startY,
                size: CGFloat.random(in: 6...10),
                color: colors.randomElement() ?? .yellow,
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            newParticles.append(particle)
        }
        self.particles = newParticles
    }
    
    private func startAnimation(in size: CGSize) {
        withAnimation(.easeOut(duration: 2.5)) {
            for i in particles.indices {
                particles[i].x += CGFloat.random(in: -40...40)
                particles[i].y += CGFloat.random(in: size.height * 0.5...size.height * 0.95)
                particles[i].rotation += Double.random(in: 180...720)
                particles[i].opacity = 0.0
            }
        }
    }
}
