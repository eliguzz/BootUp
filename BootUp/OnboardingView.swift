//
//  OnboardingView.swift
//  BootUp
//

import SwiftUI

struct OnboardingView: View {

    let slides: [OnboardingSlide]
    let finishButtonLabel: String

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    init(
        slides: [OnboardingSlide] = onboardingSlides,
        finishButtonLabel: String = "GET STARTED"
    ) {
        self.slides = slides
        self.finishButtonLabel = finishButtonLabel
    }

    private var slide: OnboardingSlide { slides[currentIndex] }
    private var isLast: Bool { currentIndex == slides.count - 1 }
    private var isFirst: Bool { currentIndex == 0 }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // Top bar — skip button
                HStack {
                    Spacer()
                    Button("SKIP") { dismiss() }
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalFaint)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                // Paged video area — swipe disabled
                TabView(selection: $currentIndex) {
                    ForEach(slides) { slide in
                        LoopingVideoPlayer(
                            videoName: slide.videoName,
                            videoExtension: "mp4"
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.terminalFaint, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .gesture(DragGesture())   // swallows the swipe gesture
                .animation(.easeInOut(duration: 0.25), value: currentIndex)

                // Text content
                VStack(alignment: .leading, spacing: 12) {
                    Text("STEP \(currentIndex + 1) / \(slides.count)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalFaint)

                    Text(slide.title)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.terminal)

                    Text(slide.body)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(.terminalDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(slides) { s in
                        Circle()
                            .fill(s.id == currentIndex ? Color.terminal : Color.terminalFaint)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 24)

                Spacer()

                // Bottom buttons
                HStack(spacing: 12) {
                    Button {
                        withAnimation { currentIndex -= 1 }
                    } label: {
                        Text("BACK")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.terminal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terminalFaint)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .opacity(isFirst ? 0.3 : 1.0)
                    .disabled(isFirst)

                    Button {
                        if isLast {
                            dismiss()
                        } else {
                            withAnimation { currentIndex += 1 }
                        }
                    } label: {
                        Text(isLast ? finishButtonLabel : "NEXT")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.appBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terminal)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled()
    }
}
