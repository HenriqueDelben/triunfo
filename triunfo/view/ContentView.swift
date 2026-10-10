//
//  ContentView.swift
//  triunfo
//
//  Created by Henrique Delben on 09/09/26.
//

import SwiftUI
import Foundation

enum TriunfoTabs: Hashable {
    case notes
    case inbox
    case tasks
    case capture
}

struct ContentView: View {
    @State private var selection: TriunfoTabs = .inbox
    @State private var showCaptureSheet = false
    
    var body: some View {
        ZStack() {
            TabView(selection: $selection) {
                Tab("Notes", systemImage: "book.pages.fill", value: .notes) {
                    Text("notes")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(.red)
                        .ignoresSafeArea()
                }
                Tab("Inbox", systemImage: "tray.fill", value: .inbox) {
                    InboxView()
                }
                
                Tab("Tasks", systemImage: "checklist", value: .tasks) {
                    Text("tasks")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .ignoresSafeArea()
                }
                Tab("", systemImage: "plus.circle.fill", value: .capture, role: .search) { }
            }
            .onChange(of: selection) { oldValue, newValue in
                if (newValue == .capture) {
                    selection = oldValue
                    showCaptureSheet = true
                }
            }

            if showCaptureSheet == true {
                Color.black.opacity(0.35)
                    .zIndex(1)
                    .transition(.opacity)
                    .onTapGesture {
                        showCaptureSheet = false
                    }

                CaptureSheet(showSheet: $showCaptureSheet)
                .zIndex(2)
            }
        }
        .task() {
            try? await Task.sleep(until: .now + .seconds(0.09))
            showCaptureSheet = true
        }
        .animation(.smooth(duration: 0.22, extraBounce: 0), value: showCaptureSheet)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
