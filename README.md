# RedLine
>### NSLayoutConstraint 제작 도우미
>
>## 개요
>> item1 관계 multiplier * item2 + constant
>## 생성
>>```swift
>>extension UIView {
>>    var rl:RedLine {
>>        return .init(this: self)
>>    }
>>}
>>let redline = UIView().rl
>>
>## 속성
>>[left,right,leading,trailing,top,bottom,centerX,centerY] 등 NSLayoutConstraint.Attribute 와 같음
>>
>## 리턴
>>```swift
>>[NSLayoutConstraint]
>>```
>>
>## 사용
>>```swift
>>view.rl.top.leading == view.superview!
>>view.rl.width == contents.rl.width + 20
>>view.rl.width <= 0.7 * view.superview!.width
>>view.rl.height >= 100
>>view.rl.width == 2 * view.rl.height //1:2 ratio
>>```
>>
>## priority
>>```swift
>>(view.rl.top.leading == view.superview!).first?.priority = .init(rawValue: 1000)
>>view.rl.top.leading ^ 1000 == view.superview!
>>view.rl.top.leading == view.superview!.rl ^ 1000
>>```
>>
>## constant
>>```swift
>>let layoutConstraint = (view.rl.width == view.superview!).first
>>layoutConstraint?.const = -100
>>layoutConstraint?.const = 0
>>layoutConstraint?.const = 100
>>```
