# CHANGELOG

## [Next]
 - Reset effects after they are done so that they can be repeated
 - Remove integrated joystick buttons
 - Add `MarginHudComponent`, used when components need to have a margin to the viewport edge
 - Refactor `JoystickComponent`
 - Add `SpriteAnimationWidget.asset`
 - Add `SpriteWidget.asset`
 - Add `SpriteButton.asset`
 - Add `NineTileBox.asset`
 - Rename `Camera.cameraSpeed` to `Camera.speed`
 - Rename `addShape` to `addHitbox` in `Hitbox` mixin

## [1.0.0-releasecandidate.13]
 - Fix camera not ending up in the correct position on long jumps
 - Make the `JoystickPlayer` a `PositionComponent`
 - Extract shared logic when handling components set in BaseComponent and BaseGame to ComponentSet.
 - Rename `camera.shake(amount: x)` to `camera.shake(duration: x)`
 - Fix `SpriteAnimationComponent` docs to use `Future.wait`
 - Add an empty `postRender` method that will run after each components render method
 - Rename `Tapable` to `Tappable`
 - Fix `SpriteAnimationComponent` docs to use `Future.wait`
 - Add an empty `postRender` method that will run after each components render method
 - Rename `HasTapableComponents` to `HasTappableComponents`
 - Rename `prepareCanvas` to `preRender`
 - Add `intensity` to `Camera.shake`
 - `FixedResolutionViewport` to use matrix transformations for `Canvas`

## [1.0.0-releasecandidate.12]
 - Fix link to code in example stories
 - Fix RotateEffect with negative deltas
 - Add isDragged to Draggable
 - Fix anchor of rendered text in TextComponent
 - Add new extensions to handle math.Rectangles nicely
 - Implement color parsing methods
 - Migrated the `Particle` API to `Vector2`
 - Add copyWith function to TextRenderer
 - Fix debug mode is not propagated to children of non-Position components
 - Fix size property of TextComponent was not correctly set
 - Fix anchor property was being incorrectly passed along to text renderer
 - All components take priority as an argument on their constructors
 - Fix renderRotated
 - Use QueryableOrderedSet for Collidables
 - Refactor TextBoxComponent
 - Fix bugs with TextBoxComponent
 - Improve error message for composed components
 - Fix `game.size` to take zoom into consideration 
 - Fix `camera.followComponent` when `zoom != 1`
 - Add `anchor` for `ShapeComponent` constructor
 - Fix rendering of polygons in `ShapeComponent`
 - Add `SpriteAnimation` support to parallax
 - Fix `Parallax` alignment for images with different width and height
 - Fix `ImageComposition` image bounds validation
 - Improved the internal `RenderObject` widget performance
 - Add `Matrix4` extensions
 - `Camera.apply` is done with matrix transformations
 - `Camera` zooming is taking current `relativeOffset` into account
 - Fix gestures for when `isHud = true` and `Camera` is modified
 - Fix `Camera` zoom behaviour with offset/anchor

## [1.0.0-releasecandidate.11]
 - Replace deprecated analysis option lines-of-executable-code with source-lines-of-code
 - Fix the anchor of SpriteWidget
 - Add test for re-adding previously removed component
 - Add possibility to dynamically change priority of components
 - Add onCollisionEnd to make it possible for the user to easily detect when a collision ends
 - Adding test coverage to packages
 - Possibility to have non-fullscreen ParallaxComponent
 - No need to send size in ParallaxComponent.fromParallax since Parallax already contains it
 - Fix Text Rendering not working properly
 - Add more useful methods to the IsometricTileMap component
 - Add Hoverables
 - Brief semantic update to second tutorial.

## [1.0.0-rc10]
 - Updated tutorial documentation to indicate use of new version
 - Fix bounding box check in collision detection
 - Refactor on flame input system to correctly take camera into account
 - Adding `SpriteAnimationGroupComponent`
 - Allow isometric tile maps with custom heights
 - Add a new renderRect method to Sprite
 - Addresses the TODO to change the camera public APIs to take Anchors for relativePositions
 - Adds methods to support moving the camera relative to its current position
 - Abstracting the text api to allow custom text renderers on the framework
 - Set the same debug mode for children as for the parent when added
 - Fix camera projections when camera is zoomed
 - Fix collision detection system with angle and parentAngle
 - Fix rendering of shapes that aren't HitboxShape

## [1.0.0-rc9]
 - Fix input bug with other anchors than center
 - Fixed `Shape` so that the `position` is now a `late`
 - Updated the documentation for the supported platforms
 - Add clear function to BaseGame to allow the removal of all components
 - Moving tutorials to the Flame main repository
 - Transforming `PaletteEntry.paint` to be a method instead of a getter
 - Adding some more basic colors entries to the `BasicPalette`
 - Fixing Flutter and Dart version constraints
 - Exporting Images and AssetsCache
 - Make `size` and `position` in `PositionComponent` final
 - Add a `snapTo` and `onPositionUpdate` method to the `Camera`
 - Remove the SpriteAnimationComponent when the animation is really done, not when it is on the last frame
 - Revamp all the docs to be up to date with v1.0.0
 - Make Assets and Images caches have a configurable prefix
 - Add `followVector2` method to the `Camera`
 - Make `gameRef` late
 - Fix Scroll example
 - Add a `renderPoint` method to `Canvas`
 - Add zoom to the camera
 - Add `moveToTarget` as an extension method to `Vector2`
 - Bring back collision detection examples
 - Fix collision detection in Collidable with multiple offset shapes
 - Publishing Flame examples on github pages

## 1.0.0-rc8
 - Migrate to null safety
 - Refactor the joystick code
 - Fix example app
 - Rename points to intersectionPoints for collision detection
 - Added CollidableType to make collision detection more efficient
 - Rename CollidableType.static to passive
 - Add srcPosition and srcSize for SpriteComponent
 - Improve collision detection with bounding boxes

## 1.0.0-rc7
 - Moving device related methods (like `fullScreen`) from `util.dart` to `device.dart`
 - Moving render functions from `util.dart` to `extensions/canvas.dart`
 - Adapting ParallaxComponent contructors to match the pattern followed on other components
 - Adapting SpriteBatchComponent constructors to match the pattern used on other components
 - Improving Parallax APIs regarding handling its size and the use outside FCS
 - Enabling direct import of Sprite and SpriteAnimation
 - Renamed `Composition` to `ImageComposition` to prevent confusion with the composition component
 - Added `rotation` and `anchor` arguments to `ImageComposition.add`
 - Added `Image` extensions
 - Added `Color` extensions
 - Change RaisedButton to ElevatedButton in timer example
 - Overhaul the draggables api to fix issues relating to local vs global positions
 - Preventing errors caused by the premature use of size property on game
 - Added a hitbox mixin for PositionComponent to make more accurate gestures
 - Added a collision detection system
 - Added geometrical shapes
 - Fix `SpriteAnimationComponent.shouldRemove` use `Component.shouldRemove`
 - Add assertion to make sure Draggables are safe to add
 - Add utility methods to the Anchor class to make it more "enum like"
 - Enable user-defined anchors
 - Added `toImage` method for the `Sprite` class
 - Uniform use of `dt` instead of `t` in all update methods
 - Add more optional arguments for unified constructors of components
 - Fix order that parent -> children render in

## 1.0.0-rc6
 - Use `Offset` type directly in `JoystickAction.update` calculations
 - Changed `parseAnchor` in `examples/widgets` to throw an exception instead of returning null when it cannot parse an anchor name
 - Code improvements and preparing APIs to null-safety
 - BaseComponent removes children marked as shouldRemove during update
 - Use `find` instead of `globstar` pattern in `scripts/lint.sh` as the later isn't enabled by default in bash
 - Fixes aseprite constructor bug
 - Improve error handling for the onLoad function
 - Add test for child removal
 - Fix bug where `Timer` callback doesn't fire for non-repeating timers, also fixing bug with `Particle` lifespan
 - Adding shortcut for loading Sprites and SpriteAnimation from the global cache
 - Adding loading methods for the different `ParallaxComponent` parts and refactor how the delta velocity works
 - Add tests for `Timer` and fix a bug where `progress` was not reported correctly
 - Refactored the `SpriteBatch` class to be more elegant and to support `Vector2`.
 - Added fallback support for the web on the `SpriteBatch` class
 - Added missing documentation on the `SpriteBatch` class
 - Added an utility method to load a `SpriteBatch` on the `Game` class
 - Updated the `widgets.md` documentation
 - Removing methods `initialDimensions` and `removeGestureRecognizer` to avoid confusion
 - Adding standard for `SpriteComponent` and `SpriteAnimationComponent` constructors
 - Added `Composition`, allows for composing multiple images into a single image.
 - Move files to comply with the dart package layout convention
 - Fix gesture detection bug of children of `PositionComponent`
 - The `game` argument on `GameWidget` is now required

## 1.0.0-rc5
 - Option for overlays to be already visible on the GameWidget
 - Adding game to the overlay builder
 - Rename retreive -> Retrieve
 - Use internal children set in BaseComponent (fixes issue adding multiple children)
 - Remove develop branches from github workflow definition
 - BaseComponent to return UnmodifiableListView for children

## 1.0.0-rc4
 - Rename Dragable -> Draggable
 - Set loop member variable when constructing SpriteAnimationComponent from SpriteAnimationData
 - Effect shouldn't affect unrelated properties on component
 - Fix rendering of children
 - Explicitly define what fields an effect on PositionComponent modifies
 - Properly propagate onMount and onRemove to children
 - Adding Canvas extensions
 - Remove Resizable mixin
 - Use config defaults for TextBoxComponent
 - Fixing Game Render Box for flutter >= 1.25
 - DebugMode to be variable instead of function on BaseGame

## 1.0.0-rc3
 - Fix TextBoxComponent rendering
 - Add TextBoxConfig options; margins and growingBox
 - Fix debugConfig strokeWidth for web
 - Update Forge2D docs
 - Update PR template with removal of develop branch
 - Translate README to Russian
 - Split up Component and PositionComponent to BaseComponent
 - Unify multiple render methods on Sprite
 - Refactored how games are inserted into a flutter tree
 - Refactored the widgets overlay API
 - Creating new way of loading animations and sprites
 - Dragable mixin for components
 - Fix update+render of component children
 - Update documentation for SVG component
 - Update documentation for PositionComponent
 - Adding Component#onLoad
 - Moving size to Game instead of BaseGame
 - Fix bug with ConcurrentModificationError on add in onMount

## 1.0.0-rc2
 - Improve IsometricTileMap and Spritesheet classes
 - Export full vector_math library from extension
 - Added warning about basic and advanced detectors
 - Ensuring sprite animation and sprite animation components don't get NPEs on initialization
 - Refactor timer class
 - include all changed that are included on 0.28.0
 - Rename game#resize to game#onResize
 - Test suite for basic effects
 - Effects duration and test suite for basic effects
 - Pause and resume for effects
 - Fix position bug in parallax effect
 - Simplification of BaseGame. Removal of addLater (add is now addLater) and rename markForRemoval.
 - Unify naming for removal of components from BaseGame

## 1.0.0-rc1
 - Move all box2d related code and examples to the flame_box2d repo
 - Rename Animation to SpriteAnimation
 - Create extension of Vector2 and unify all tuples to use that class
 - Remove Position class in favor of new Vector2 extension
 - Remove Box2D as a dependency
 - Rebuild of Images, Sprite and SpriteAnimation initialization
 - Use isRelative on effects
 - Use Vector2 for position and size on PositionComponent
 - Removing all deprecated methods
 - Rename `resize` method on components to `onGameResize`
 - Make `Resizable` have a `gameSize` property instead of `size`
 - Fix bug with CombinedEffect inside SequenceEffect
 - Fix wrong end angle for relative rotational effects
 - Use a list of Vector2 for Move effect to open up for more advanced move effects
 - Generalize effects api to include all components
 - Extract all the audio related capabilities to a new package, flame_audio
 - Fix bug that sprite crashes without a position

## 0.29.1-beta
 - Fixing Game Render Box for flutter >= 1.25

## 0.29.0
- Update audioplayers to latest version (now `assets` will not be added to prefixes automatically)
- Fix lint issues with 0.28.0

## 0.28.0
- Fix spriteAsWidget deprecation message
- Add `lineHeight` property to `TextConfig`
- Adding pause and resume methods to time class

## 0.27.0
 - Improved the accuracy of the `FPSCounter` by using Flutter's internal frame timings.
 - Adding MouseMovementDetector
 - Adding ScrollDetector
 - Fixes BGM error
 - Adding Isometric Tile Maps

## 0.26.0
 - Improving Flame image auto cache
 - Fix bug in the Box2DGame's add and addLater method , when the Component extends BodyComponent and mixin HasGameRef or other mixins ,the mixins will not be set correctly

## 0.25.0
 - Externalizing Tiled support to its own package `flame_tiled`
 - Preventing some crashs that could happen on web when some methods were called
 - Add mustCallSuper to BaseGame `update` and `render` methods
 - Moved FPS code from BaseGame to a mixin, BaseGame uses the new mixin.
 - Deprecate flare API in favor of the package `flame_flare`

## 0.24.0
 - Outsourcing SVG support to an external package
 - Adding MemoryCache class
 - Fixing games crashes on Web
 - Update tiled dependency to 0.6.0 (objects' properties are now double)

## 0.23.0
 - Add Joystick Component
 - Adding BaseGame#markToRemove
 - Upgrade tiled and flutter_svg dependencies
 - onComplete callback for effects
 - Adding Layers
 - Update tiled dep to 0.5.0 and add support for rotation with improved api

## 0.22.1
 - Fix Box2DComponent render priority
 - Fix PositionComponentEffect drifting
 - Add possibility to combine effects
 - Update to newest box2d_flame which fixes torque bug
 - Adding SpriteSheet.fromImage

## 0.22.0
 - Fixing BaseGame tap detectors issues
 - Adding SpriteWidget
 - Adding AnimationWidget
 - Upgrade Flutter SVG to fix for flame web
 - Add linting to all the examples
 - Run linting only on affected and changed examples
 - Add SequenceEffect
 - Fixed bug with travelTime in RotateEffect

## 0.21.0
- Adding AssetsCache.readBinaryFile
- Splitting debugMode from recordFps mode
- Adding support for multi touch tap and drag events
- Fix animations example
- Add possibility for infinite and alternating effects
- Add rotational effect for PositionComponents

## 0.20.2
- Fix text component bug with anchor being applied twice

## 0.20.1
- Adding method to load image bases on base64 data url.
- Fix Box2DGame to follow render priority
- Fix games trying to use gameRef inside the resize function

## 0.20.0
- Refactor game.dart classes into separate files
- Adding a GameLoop class which uses a Ticker for updating game
- Adding sprites example
- Made BaseGame non-abstract and removed SimpleGame
- Adding SpriteButton Widget
- Added SpriteBatch API, which renders sprites effectively using Canvas.drawAtlas
- Introducing basic effects API, including MoveEffect and ScaleEffect
- Adding ContactCallback controls in Box2DGame

## 0.19.1
 - Bump AudioPlayers version to allow for web support
 - Adding Game#pauseEngine and Game#resumeEngine methods
 - Removing FlameBinding since it isn't used and clashes with newest flutter

## 0.19.0
 - Fixing component lifecycle calls on BaseGame#addLater
 - Fixing Component#onDestroy, which was been called multiple times sometimes
 - Fixing Widget Overlay usage over many game instances

## 0.18.3
- Adding Component#onDestroy
- Adding Keyboard events API
- Adding Box2DGame, an extension of BaseGame to simplify lifecycle of Box2D components
- Add onAnimateComplete for Animation (thanks @diegomgarcia)
- Adding AnimationComponent#overridePaint
- Adding SpriteComponent#overridePaint
- Updating AudioPlayers to enable Web Audio support

## 0.18.2
- Add loop for AnimationComponent.sequenced() (thanks @wenxiangjiang)
- TextComponent optimization (thanks @Gericop)
- Adding Component#onMount
- Check if chidren are loaded before rendering on ComposedComponent (thanks @wenxiangjiang)
- Amend type for width and height properties on Animation.sequenced (thanks @wenxiangjiang)
- Fixing Tapable position checking
- Support line feed when create animation from a single image source (thanks @wenxiangjiang)
- Fixing TextBoxComponent start/end of line bugs (thanks @kurtome)
- Prevent widgets overlay controller from closing when in debug mode


## 0.18.1
- Expose stepTime paramter from the Animation class to the animation component
- Updated versions for bugfixes + improved macOS support. (thanks @flowhorn)
- Update flutter_svg to 0.17.1 (thanks @flowhorn)
- Update audioplayers to 0.14.0 (thanks @flowhorn)
- Update path_provider to 1.6.0 (thanks @flowhorn)
- Update ordered_set to 1.1.5 (thanks @flowhorn)

## 0.18.0
- Improving FlareComponent API and updating FlareFlutter dependency
- Adding HasWidgetsOverlay mixin
- Adding NineTileBox widget

## 0.17.4
- Fixing compilations errors regarding changes on `box2_flame`
- Add splash screen docs

## 0.17.3
- Tweaking text box rendering to reduce pixelated text (thanks, @kurtome)
- Adding NineTileBox component

## 0.17.2
- Added backgroundColor method for overriding the game background (thanks @wolfenrain)
- Update AudioPlayers version to 0.13.5
- Bump SVG dependency plus fix example app

## 0.17.1
- Added default render function for Box2D ChainShape
- Adding TimerComponent
- Added particles subsystem (thanks @av)

## 0.17.0
- Fixing FlareAnimation API to match convention
- Fixing FlareComponent renderization
- New GestureDetector API to Game

## 0.16.1
- Added `Bgm` class for easy looping background music management.
- Added options for flip rendering of PositionComponents easily (horizontal and vertical).

## 0.16.0
- Improve our mixin structure (breaking change)
- Adds HasGameRef mixin
- Fixes for ComposedComponent (for tapables and other apis using preAdd)
- Added no-parameter alias functions for setting the game's orientation.
- Prevent double completion on onMetricsChanged callback

## 0.15.2
- Exposing tile objects on TiledComponent (thanks @renatoferreira656)
- Adding integrated API for taps on Game class and adding Tapeables mixin for PositionComponents

## 0.15.1
- Bumped version of svg dependency
- Fixed warnings

## 0.15.0
- Refactoring ParallaxComponent (thanks @spydon)
- Fixing flare animation with embed images
- Adding override paint parameter to Sprite, and refactoring it have named optional parameters

## 0.14.2
- Refactoring BaseGame debugMode
- Adding SpriteSheet class
- Adding Flame.util.spriteAsWidget
- Fixing AnimationComponent.empty()
- Fixing FlameAudio.loopLongAudio

## 0.14.1
- Fixed build on travis
- Updated readme badges
- Fixed changelog
- Fixed warning on audiopool, added audiopool example in docs

## 0.14.0
- Adding Timer#isRunning method
- Adding Timer#progress getter
- Updating Flame to work with Flutter >= 1.6.0

## 0.13.1
- Adding Timer utility class
- Adding `destroyOnFinish` flag for AnimationComponent
- Fixing release mode on examples that needed screen size
- Bumping dependencies versions (audioplayers and path_provider)

## 0.13.0
- Downgrading flame support to stable channel.

## 0.12.2
- Added more functionality to the Position class (thanks, @illiapoplawski)

## 0.12.1
- Fixed PositionComponent#setByRect to comply with toRect (thanks, @illiapoplawski)

## 0.12.0
- Updating flutter_svg and pubspec to support the latest flutter version (1.6.0)
- Adding Flare Support
- Fixing PositionComponent#toRect which was not considering the anchor property (thanks, @illiapoplawski)

## [0.11.2]
- Fixed bug on animatons with a single frame
- Fixed warning on using specific version o flutter_svg on pubspec
- ParallaxComponent is not abstract anymore, as it does not include any abstract method
- Added some functionality to Position class

## [0.11.1]
- Fixed lack of paint update when using AnimationAsWidget as pointed in #78
- Added travis (thanks, @renancarujo)

## [0.11.0]
- Implementing low latency api from audioplayers (breaking change)
- Improved examples by adding some instructions on how to run
- Add notice on readme about the channel
- Upgrade path_provider to fix conflicts

## [0.10.4]
- Fix breaking change on svg plugin

## [0.10.3]
- Svg support
- Adding `Animation#reversed` allowing a new reversed animation to be created from an existing animation.
- Fix games inside regular apps when the component is inside a sliver
- Support asesprite animations

## [0.10.2]
- Fixed some warnings and formatting

## [0.10.1]
- Fixes some typos
- Improved docs
- Extracted gamepads to a new lib, lots of improvements there (thanks, @erickzanardo)
- Added more examples and an article

## [0.10.0]
- Fixing a few minor bugs, typos, improving docs
- Adding the Palette concept: easy access to white and black colors/paints, create your palette to keep your game organized.
- Adding the Anchor concept: specify where thins should anchor, added to PositionComponent and to the new text releated features.
- Added a whole bunch of text related components: TextConfig allows you to easily define your typography information, TextComponent allows for easy rendering of stuff and TextBox can make sized texts and also typing effects.
- Improved Utils to have better and more concise APIs, removed unused stuff.
- Adding TiledComponent to integrate with tiled

## [0.9.5]
- Add `elapsed` property to Animation (thanks, @ianliu)
- Fixed minor typo on documentation

## [0.9.4]
- Bumps audioplayers version

## [0.9.3]
- Fixes issue when switching between games where new game would not attach

## [0.9.2]
- Fixes to work with Dart 2.1

## [0.9.1]
- Updated audioplayers and box2d to fix bugs

## [0.9.0]
- Several API changes, using new audioplayers 0.6.x

## [0.8.4]
- Added more consistent APIs and tests

## [0.8.3]
- Need to review audioplayers 0.5.x

## [0.8.2]
- Added better documentation, tutorials and examples
- Minor tweaks in the API
- New audioplayers version

## [0.8.1]
- The Components Overhaul Update: This is major update, even though we are keeping things in alpha (version 0.*)
- Several major upgrades regarding the component system, new component types, Sprites and SpriteSheets, better image caching, several improvements with structure, a BaseGame, a new Game as a widget, that allows you to embed inside apps and a stop method. More minor changes.

## [0.6.1]
 - Bump required dart version

## [0.6.0]
 - Adding audio suport for iOS (bumping audioplayers version)

## [0.5.0]
 - Adding a text method to Util to more easily render a Paragraph

## [0.4.0]
 - Upgraded AudioPlayers, added method to disable logging
 - Created PositionComponent with some useful methods
 - A few refactorings

## [0.3.0]
 - Added a pre-load method for Audio module

## [0.2.0]
 - Added a loop method for playing audio on loop
 - Added the option to make rectangular SpriteComponents, not just squares

## [0.1.0]
 - First release, basic utilities
