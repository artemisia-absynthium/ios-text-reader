# iOS Text Reader

## Project Archived

Since iOS 11, Apple released [Vision](https://developer.apple.com/documentation/vision), their powerful computer vision framework, including [OCR](https://developer.apple.com/documentation/vision/recognizing_text_in_images) capabilities. I strongly recommend using it because it's very easy to use and well performing. That said I'm no longer maintaining this project, I'm archiving it and leaving it here for history.

---

This iOS app uses [gali8/Tesseract-OCR-iOS](https://github.com/gali8/Tesseract-OCR-iOS) to recognize text from
images taken from live camera preview.

## Setup

This project uses [Cocoapods](https://cocoapods.org/) as a dependency manager, after checkout, run `pod install`
from inside the project folder.
If you don't have Cocoapods installed, here's the [official reference](https://cocoapods.org/) to get you started.

### Language

Recognition is now coded to work with Italian and English language.
In order to use another language
* Checkout [tesseract-ocr/langdata](https://github.com/tesseract-ocr/langdata)
* Replace all `ita.*` files in the `TextReader/tessdata` folder with the desired ones
(all of the files in your language folder are needed if you don't change [recognition mode](#recognition-mode))
* In `ViewController.swift`, row 17, replace `ita` with the 3 letters code of the language you chose
* Edit the char whitelist in `ViewController.swift`, row 26, to tailor alphabet and punctuation to the ones
you expect to find in your text, or delete the row to keep it general.

As of my experience I suggest to maintain `eng.*` files even if you don't actually need them because they empirically seem to
enhance the precision of the recognition of other languages as well.

### Recognition Mode

The app, as is, uses both recognition modes: Tesseract and Cube.
By using both of them it's way more precise but slower too, so you may want to try using Tesseract only mode first, that's the
fastest, to check whether it's enough to suit your needs. In order to change it, during Tesseract initialization 
(`ViewController.swift`, rows 25-27) set `G8Tesseract.engineMode` to `.tesseractOnly`.

If you find that's good for you, then you can delete all of the files in the `TextReader/tessdata` except for the ones called
`*.traineddata`, because the other files are used only by Cube. In this way you'll sensibly reduce your app size, too.

## Configuration

For more configuration fine tuning, I strongly advice you to check these pages of the gali8/Tesseract-OCR-iOS documentation
* [Advanced Tesseract Configuration](https://github.com/gali8/Tesseract-OCR-iOS/wiki/Advanced-Tesseract-Configuration)
* [Tips for Improving OCR Results](https://github.com/gali8/Tesseract-OCR-iOS/wiki/Tips-for-Improving-OCR-Results)
