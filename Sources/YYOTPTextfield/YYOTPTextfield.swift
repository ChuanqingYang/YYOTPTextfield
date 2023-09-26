// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 17.0, *)
public struct YYOTPTextfieldConfig {
    
    public enum Style {
        case underline
        case rect
    }
    
    
    public var style: Style = .rect
    /// for both ``rect`` and ``underline``
    public var activeBorderColor: Color = .black
    public var inactiveBorderColor: Color = .gray
    
    /// if set to ``yes`` then it will enable ``underline`` style to got a backgound
    /// which is ``false`` by default
    public var enableBackground:Bool = false
    public var activeBackgroundColor: Color = .gray
    public var inactiveBackgroundColor: Color = .gray.opacity(0.5)
    
    public var activeTextColor:Color = .black
    public var inactiveTextColor: Color = .gray
    
    /// only effective when ``Style`` equals to ``rect``
    public var cornerRadius: CGFloat = 8
    
    public var textFont: Font = .system(size: 36, weight: .bold, design: .rounded)
    
    ///  when ``style`` equals to ``underline`` the ``width`` will be apply to
    ///  the ``height``
    public var boxSize: CGSize = CGSize(width: 45, height: 45)
    
    /// set it to true means when the input code reachs the
    /// otpcount then it will callback completions
    public var enableAutoCompletion: Bool = false
    
    public init(style: Style = .rect,
                activeBorderColor: Color = .black,
                inactiveBorderColor: Color = .gray,
                enableBackground: Bool = false,
                activeBackgroundColor: Color = .gray,
                inactiveBackgroundColor: Color = .gray.opacity(0.5),
                activeTextColor: Color = .black,
                inactiveTextColor: Color = .gray,
                cornerRadius: CGFloat = 8,
                textFont: Font = .system(size: 36, weight: .bold, design: .rounded),
                boxSize: CGSize = CGSize(width: 45, height: 55),
                enableAutoCompletion: Bool = false) {
        self.style = style
        self.activeBorderColor = activeBorderColor
        self.inactiveBorderColor = inactiveBorderColor
        self.enableBackground = enableBackground
        self.activeBackgroundColor = activeBackgroundColor
        self.inactiveBackgroundColor = inactiveBackgroundColor
        self.activeTextColor = activeTextColor
        self.inactiveTextColor = inactiveTextColor
        self.cornerRadius = cornerRadius
        self.textFont = textFont
        self.boxSize = boxSize
        self.enableAutoCompletion = enableAutoCompletion
    }
    
}

@available(iOS 17, *)
public struct YYOTPTextfield: View {
    
    public var otpCount: Int = 6
    public var config: YYOTPTextfieldConfig = .init()
    public var completion:(String) -> ()
    
    @State private var otpText:String = ""
    
    @FocusState private var focusState
    @State private var isKeyboardShow: Bool = false
    
    @State private var indicator:Bool = false
    private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    public init(otpCount: Int = 6,
         config: YYOTPTextfieldConfig = .init(),
         completion: @escaping (String) -> Void) {
        self.otpCount = otpCount
        self.config = config
        self.completion = completion
    }
    
    public var body: some View {
        ZStack {
            
            TextField("", text: $otpText.limit(otpCount))
                .keyboardType(.numberPad)
                .focused($focusState)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .onChange(of: otpText) { oldValue, newValue in
                    if newValue.count == otpCount && config.enableAutoCompletion {
                        completion(newValue)
                    }
                }
            
            HStack(spacing: 0) {
                ForEach(0..<otpCount,id: \.self) { index in
                    OTPBox(index)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                focusState = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusState = false
                    
                    completionSafeCheck()
                }
                .frame(maxWidth: .infinity,alignment: .trailing)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification), perform: { _ in
            isKeyboardShow = true
        })
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
            isKeyboardShow = false
        })
        .onReceive(timer, perform: { _ in
            withAnimation(.smooth(duration: 0.3)) {
                indicator.toggle()
            }
        })
        
    }
    
    func completionSafeCheck() {
        if otpText.count == otpCount {
            completion(otpText)
        }
    }
    
    @ViewBuilder
    func OTPBox(_ index: Int) -> some View {
        
        ZStack {
            /// /// safe check
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
                    .foregroundStyle(otpText.count > index && isKeyboardShow ? config.activeTextColor : config.inactiveTextColor)
            }else {
                Text(" ")
            }
        }
        .frame(width: config.boxSize.width, height: config.style == .underline ? config.boxSize.width : config.boxSize.height)
        .background {
            if config.style == .rect {
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .fill(otpText.count > index && isKeyboardShow ? config.activeBackgroundColor : config.inactiveBackgroundColor)
                    .stroke(otpText.count > index && isKeyboardShow ? config.activeBorderColor : config.inactiveBorderColor, lineWidth: 1)
                    .overlay {
                        RoundedRectangle(cornerRadius: config.cornerRadius)
                            .stroke(otpText.count == index && isKeyboardShow && indicator ? config.activeBorderColor : config.inactiveBorderColor)
                    }
            }else {
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .fill(config.enableBackground ? otpText.count > index && isKeyboardShow ? config.activeBackgroundColor : config.inactiveBackgroundColor : .clear)
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: config.boxSize.height / 2)
                            .fill(otpText.count > index && isKeyboardShow ? config.activeBorderColor : config.inactiveBorderColor)
                            .frame(width: config.boxSize.width, height: config.boxSize.height)
                            .overlay {
                                RoundedRectangle(cornerRadius: config.boxSize.height / 2)
                                    .fill(otpText.count == index && isKeyboardShow && indicator ? config.activeBorderColor : config.inactiveBorderColor)
                            }
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 17, *)
extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        
        return self
    }
}

@available(iOS 17, *)
#Preview {
    YYOTPTextfield { code in }
}
