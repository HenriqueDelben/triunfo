//
//  teste.swift
//  triunfo
//
//  Created by Henrique Delben on 12/09/26.
//

import SwiftUI
import UIKit

struct CaptureSheet: View {
    @Environment(InboxManager.self) var inbox
    
    @FocusState var captureFieldFocus: Bool
    @Binding var showSheet: Bool
    @State private var entry = ""
    @State private var dragOffset = CGSize.zero
    
    public var body: some View {
        VStack {
            HStack {
                CaptureTextField(text: $entry, isFocused: $captureFieldFocus) {
                    inbox.captureEntry(with: entry)
                }
                .focused($captureFieldFocus)
                .padding()
            }
            .overlay() {
                Capsule().fill(Color.clear).strokeBorder()
            }
            Spacer()
        }
        .padding()
        .containerRelativeFrame(.vertical, {height, axis in height * 0.77})
        .background(.regularMaterial)
        .clipShape(
            UnevenRoundedRectangle(topLeadingRadius: 42, topTrailingRadius: 42)
        )
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged() { value in
                    if (value.translation.height > 0) {
                        dragOffset.height = value.translation.height
                    }
                }
                .onEnded() { value in
                    if dragOffset.height > 20 {
                        captureFieldFocus = false
                        showSheet = false
                    }
                }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onChange(of: captureFieldFocus) {
            if !captureFieldFocus {
                showSheet = false
            }
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
    }
}


struct CaptureTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = "Capture..."
    var isFocused: FocusState<Bool>.Binding
    var accessibilityIdentifier = "capture_input"
    var hasPressedReturn: () -> ()

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.accessibilityIdentifier = accessibilityIdentifier
        tf.enablesReturnKeyAutomatically = true
        tf.delegate = context.coordinator
        tf.setContentHuggingPriority(.required, for: .vertical)
        
        tf.setContentCompressionResistancePriority(.required, for: .vertical)

        DispatchQueue.main.async {
            isFocused.wrappedValue = true
        }
        
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text { uiView.text = text }

        if isFocused.wrappedValue, !uiView.isFirstResponder {
            DispatchQueue.main.async { uiView.becomeFirstResponder() }
        } else if !isFocused.wrappedValue, uiView.isFirstResponder {
            DispatchQueue.main.async { uiView.resignFirstResponder() }
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
            let width = proposal.width ?? uiView.intrinsicContentSize.width
            return CGSize(width: width, height: uiView.intrinsicContentSize.height)
        }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFocused: isFocused, hasPressedReturn: hasPressedReturn)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var isFocused: FocusState<Bool>.Binding
        var hasPressedReturn : () -> ()

        init(text: Binding<String>, isFocused: FocusState<Bool>.Binding, hasPressedReturn: @escaping () -> ()) {
            _text = text
            self.isFocused = isFocused
            self.hasPressedReturn = hasPressedReturn
        }

        func textFieldDidChangeSelection(_ tf: UITextField) { text = tf.text ?? "" }

        func textFieldDidBeginEditing(_ tf: UITextField) { isFocused.wrappedValue = true }
        func textFieldDidEndEditing(_ tf: UITextField) { isFocused.wrappedValue = false }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            hasPressedReturn()
            textField.resignFirstResponder()
            return true
        }
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    @Previewable @State var showSheet: Bool = true
    CaptureSheet(showSheet: $showSheet)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom).ignoresSafeArea()
}

