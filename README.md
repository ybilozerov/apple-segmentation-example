# apple-segmentation-example
**macOS** compatible version of the Apple's [sample code](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video) with slightly changed architecture.

The application already works in a minimal form and will be gradually expanded.<br>
Requires Xcode 13.0+ and macOS 12.0+ to build and run.

What the application already does:
- Request permission to use the camera and obtain its frames.
- Process frames to get silhouette mask using the [VNGeneratePersonSegmentationRequest](https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest).
- Blend original frames to get masked images.
- Display result.

What application will do:
- Support additional Vision features, like [VNDetectFaceRectanglesRequest](https://developer.apple.com/documentation/vision/vndetectfacerectanglesrequest).
- Support running on the iOS/iPadOS.
- Allow setup of various parameters.
- Provide better result displaying with support of different content scaling modes.
- Allow processing another sources (e.g. images).
