# Card Slider for Swift
Tons of apps use a Tinder-style interface with cards that users can swipe right to 'like' or left to 'dislike'. But [Yaroslav Zubko](https://dribbble.com/Yar_Z) came up with an innovative and fresh approach to giving users more options besides just 'like' or 'dislike'.
Here's Yaroslav's [Dribbble shot](https://dribbble.com/shots/3217240--14-Sub-Level-Slider) that inspired me to create a 100% Swift project of this unique & new interface:
<p align="center">
    <img src="https://cloud.githubusercontent.com/assets/7799382/23380926/88e837ee-fcf1-11e6-917a-49de8fc8ee13.gif" alt="Dribbble shot" />
</p>

And here's a demo of the actual Swift project:
<p align="center">
    <img src="https://cloud.githubusercontent.com/assets/7799382/23379940/ba3b91fa-fced-11e6-9639-ff50538a99d9.gif" alt="Demo" />
</p>

## Usage

This project isn't a framework, it's more so of a demonstration of how to approach this sort of user interface.
Card Slider basically uses a `UIPanGestureRecognizer` in conjunction with several `UIKit Dynamics` behaviors. Because of this, ideally you would want all the card logic code in a view controller class, so I opted not make an external class that uses delegation to talk to the view controller.

### `CardView.swift`
Most of the logic code is in the `ViewController` class, but each card is a subview of `CardView`. In the demo project, `ImageCard` is a subview of CardView and has its own custom subviews and layouts. 
You can create your own subclass of `CardView` and modify the `cards` data structure in `ViewController` to swap in your own custom cards.
You can also modify the `CardOption` enum to show your own custom text on the cards for each of the 6 options (you may even add more, but that would require dealing with more emojis and laying them out properly.)

### `EmojiOptionsOverlay.swift`
This file has all the logic code associated with showing the 6 emojis on the sides when the user pans the card around, as well as the heart emoji on the top right.

## Credits
Yaroslav Zubko, the creator of the Dribbble shot that inspired this project, was kind enough to send me his design files. This concept and any artwork (including the emojis) is thanks to Yaroslav.
https://dribbble.com/Yar_Z
