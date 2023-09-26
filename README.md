# YYOTPTextfield
A Custom OTP Code input view

> Usage

- Config your own style with `YYOTPTextfieldConfig`
  ```
  style: Style = .rect,        // rect & underline
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
  enableAutoCompletion: Bool = false,
  enableAutoResponse: Bool = false
  ```

- Add it to your View
```
  YYOTPTextfield(otpCount: 6, config: config) { code in
      /// Code comes here
  }
```
