# Brightcove iOS player plugin

## Getting Started

* Clone the project from github, cd to the `iOS` folder

* Run `bundle install` to install Ruby gems

* Run `pod install` to install third party dependencies

* Open `BrightcovePlayer.xcworkspace` with Xcode 10.

* The plugin classes will be found under `Pods`, in the `Development Pods` folder.

## Release process

### Pre-conditions

* Install [zappifest](https://github.com/applicaster/zappifest).

* Ensure that your Zapp access token is registered as `ZAPP_TOKEN` environment variables (via `export` or `.bash_profile` )

* Create a new branch named `release/x.x.x` or checkout to the current feature branch.

### Publishing new plugin version

* Execute `bundle exec fastlane submit version:x.x.x`. This will update plugin version in podspec, plugin manifest and will copy the podspec to `Specs/x.x.x` folder. It allows to use the plugin repo itself as a private [CocoaPods Spec Repo](https://guides.cocoapods.org/making/specs-and-specs-repo.html).

* Create a PR and merge it to `master`

* Create a new [Github Release](https://help.github.com/articles/creating-releases/) with the version number used in previous steps. As an alternative, you can add git tag to the `HEAD` of `master` branch and push it to the `origin` repo.

* Publish plugin manifest to Zapp by invoking `zappifest publish --manifest iOS/BrightcovePlayer/plugin_manifest.json`