# PCLBlurEffectAlert

Swift AlertController, use UIVisualeffectview

<img src="https://raw.githubusercontent.com/wiki/hryk224/PCLBlurEffectAlert/images/sample1.gif" width="320" > <img src="https://raw.githubusercontent.com/wiki/hryk224/PCLBlurEffectAlert/images/sample2.gif" width="320" >

## Requirements
- iOS 8.0+
- Swift 2.0+
- ARC

## Feature
- [x] Change color
- [x] Change effect
- [x] Change font
- [x] Use UITextField

## install

#### Cocoapods

Adding the following to your `Podfile` and running `pod install`:

```Ruby
use_frameworks!
pod "PCLBlurEffectAlert"
```

<!--#### Carthage-->

Add the following to your `Cartfile` and running `Cartfile update`:

```Ruby
github "hryk224/PCLBlurEffectAlert"
```

### import

```Swift
import PCLBlurEffectAlert
```

## Usage

```Swift
let alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title", message: nil, style: .Alert)
let action1 = PCLBlurEffectAlert.AlertAction(title: "yes", style: .Destructive, handler: { action in  print("yes") })
alertController.addAction(action)

// customize
alertController.configure(cornerRadius: 20)
alertController.configure(buttonDisableTextColor: [.Destructive: UIColor.redColor()])
presentViewController(alertController, animated: true, completion: nil)
```

## Acknowledgements

* Inspired by [DOAlertController](https://github.com/okmr-d/DOAlertController) in [okmr-d](https://github.com/okmr-d).

##License

This project is made available under the MIT license. See LICENSE file for details.
