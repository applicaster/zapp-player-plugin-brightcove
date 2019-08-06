import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  requireNativeComponent,
  NativeModules,
  Image,
  View,
  ViewPropTypes
} from "react-native";
import PropTypes from "prop-types";
import { assetsFromSource, resizeModeFromMapping } from "../../Utils";
import FilterType from "../../Const/FilterType";

const styles = StyleSheet.create({
  base: {
    overflow: "hidden"
  }
});

export default class VideoPlayer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showPoster: true
    };
  }

  setNativeProps(nativeProps) {
    this._root.setNativeProps(nativeProps);
  }

  seek = (time, tolerance = 100) => {
    if (isNaN(time)) throw new Error("Specified time is not a number");

    if (Platform.OS === "ios") {
      this.setNativeProps({
        seek: {
          time,
          tolerance
        }
      });
    } else {
      this.setNativeProps({ seek: time });
    }
  };

  presentFullscreenPlayer = () => {
    this.setNativeProps({ fullscreen: true });
  };

  dismissFullscreenPlayer = () => {
    this.setNativeProps({ fullscreen: false });
  };

  _assignRoot = component => {
    this._root = component;
  };

  _onLoadStart = event => {
    if (this.props.onLoadStart) {
      this.props.onLoadStart(event.nativeEvent);
    }
  };

  _onLoad = event => {
    if (this.props.onLoad) {
      this.props.onLoad(event.nativeEvent);
    }
  };

  _onError = event => {
    if (this.props.onError) {
      this.props.onError(event.nativeEvent);
    }
  };

  _onProgress = event => {
    if (this.props.onProgress) {
      this.props.onProgress(event.nativeEvent);
    }
  };

  _onSeek = event => {
    if (this.state.showPoster && !this.props.audioOnly) {
      this.setState({ showPoster: false });
    }

    if (this.props.onSeek) {
      this.props.onSeek(event.nativeEvent);
    }
  };

  _onEnd = event => {
    if (this.props.onEnd) {
      this.props.onEnd(event.nativeEvent);
    }
  };

  _onTimedMetadata = event => {
    if (this.props.onTimedMetadata) {
      this.props.onTimedMetadata(event.nativeEvent);
    }
  };

  _onFullscreenPlayerWillPresent = event => {
    if (this.props.onFullscreenPlayerWillPresent) {
      this.props.onFullscreenPlayerWillPresent(event.nativeEvent);
    }
  };

  _onFullscreenPlayerDidPresent = event => {
    if (this.props.onFullscreenPlayerDidPresent) {
      this.props.onFullscreenPlayerDidPresent(event.nativeEvent);
    }
  };

  _onFullscreenPlayerWillDismiss = event => {
    if (this.props.onFullscreenPlayerWillDismiss) {
      this.props.onFullscreenPlayerWillDismiss(event.nativeEvent);
    }
  };

  _onFullscreenPlayerDidDismiss = event => {
    if (this.props.onFullscreenPlayerDidDismiss) {
      this.props.onFullscreenPlayerDidDismiss(event.nativeEvent);
    }
  };

  _onReadyForDisplay = event => {
    if (this.props.onReadyForDisplay) {
      this.props.onReadyForDisplay(event.nativeEvent);
    }
  };

  _onPlaybackStalled = event => {
    if (this.props.onPlaybackStalled) {
      this.props.onPlaybackStalled(event.nativeEvent);
    }
  };

  _onPlaybackResume = event => {
    if (this.props.onPlaybackResume) {
      this.props.onPlaybackResume(event.nativeEvent);
    }
  };

  _onPlaybackRateChange = event => {
    if (
      this.state.showPoster &&
      event.nativeEvent.playbackRate !== 0 &&
      !this.props.audioOnly
    ) {
      this.setState({ showPoster: false });
    }

    if (this.props.onPlaybackRateChange) {
      this.props.onPlaybackRateChange(event.nativeEvent);
    }
  };

  _onExternalPlaybackChange = event => {
    if (this.props.onExternalPlaybackChange) {
      this.props.onExternalPlaybackChange(event.nativeEvent);
    }
  };

  _onAudioBecomingNoisy = () => {
    if (this.props.onAudioBecomingNoisy) {
      this.props.onAudioBecomingNoisy();
    }
  };

  _onAudioFocusChanged = event => {
    if (this.props.onAudioFocusChanged) {
      this.props.onAudioFocusChanged(event.nativeEvent);
    }
  };

  _onBuffer = event => {
    if (this.props.onBuffer) {
      this.props.onBuffer(event.nativeEvent);
    }
  };

  _onAdChangedState = event => {
    const { onAdChangedState } = this.props;
    const { nativeEvent } = event;
    onAdChangedState && onAdChangedState(nativeEvent);
  };

  render() {
    const { source, resizeMode } = this.props;
    const assetSource = assetsFromSource(source) || {};
    const { entry } = source;
    const nativeResizeMode = resizeModeFromMapping(
      resizeMode,
      NativeModules.UIManager.PlayerModule.Constants
    );
    const nativeProps = {
      ...this.props,
      ...{
        style: styles.base,
        resizeMode: nativeResizeMode,
        src: assetSource,
        entry: entry,
        onVideoLoadStart: this._onLoadStart,
        onVideoLoad: this._onLoad,
        onVideoError: this._onError,
        onVideoProgress: this._onProgress,
        onVideoSeek: this._onSeek,
        onVideoEnd: this._onEnd,
        onVideoBuffer: this._onBuffer,
        onTimedMetadata: this._onTimedMetadata,
        onVideoAudioBecomingNoisy: this._onAudioBecomingNoisy,
        onVideoExternalPlaybackChange: this._onExternalPlaybackChange,
        onVideoFullscreenPlayerWillPresent: this._onFullscreenPlayerWillPresent,
        onVideoFullscreenPlayerDidPresent: this._onFullscreenPlayerDidPresent,
        onVideoFullscreenPlayerWillDismiss: this._onFullscreenPlayerWillDismiss,
        onVideoFullscreenPlayerDidDismiss: this._onFullscreenPlayerDidDismiss,
        onReadyForDisplay: this._onReadyForDisplay,
        onPlaybackStalled: this._onPlaybackStalled,
        onPlaybackResume: this._onPlaybackResume,
        onPlaybackRateChange: this._onPlaybackRateChange,
        onAudioFocusChanged: this._onAudioFocusChanged,
        onAudioBecomingNoisy: this._onAudioBecomingNoisy,
        onAdChangedState: this._onAdChangedState
      }
    };
    // return <Player {...nativeProps}>{children}</Player>;
    return (
      <React.Fragment>
        <Player ref={this._assignRoot} {...nativeProps} />
        {this.props.poster && this.state.showPoster && (
          <View style={nativeProps.style}>
            <Image style={posterStyle} source={{ uri: this.props.poster }} />
          </View>
        )}
      </React.Fragment>
    );
  }
}

VideoPlayer.propTypes = {
  filter: PropTypes.oneOf([
    FilterType.NONE,
    FilterType.INVERT,
    FilterType.MONOCHROME,
    FilterType.POSTERIZE,
    FilterType.FALSE,
    FilterType.MAXIMUMCOMPONENT,
    FilterType.MINIMUMCOMPONENT,
    FilterType.CHROME,
    FilterType.FADE,
    FilterType.INSTANT,
    FilterType.MONO,
    FilterType.NOIR,
    FilterType.PROCESS,
    FilterType.TONAL,
    FilterType.TRANSFER,
    FilterType.SEPIA
  ]),
  /* Native only */
  src: PropTypes.object,
  seek: PropTypes.oneOfType([PropTypes.number, PropTypes.object]),
  fullscreen: PropTypes.bool,
  onVideoLoadStart: PropTypes.func,
  onVideoLoad: PropTypes.func,
  onVideoBuffer: PropTypes.func,
  onVideoError: PropTypes.func,
  onVideoProgress: PropTypes.func,
  onVideoSeek: PropTypes.func,
  onVideoEnd: PropTypes.func,
  onTimedMetadata: PropTypes.func,
  onVideoAudioBecomingNoisy: PropTypes.func,
  onVideoExternalPlaybackChange: PropTypes.func,
  onVideoFullscreenPlayerWillPresent: PropTypes.func,
  onVideoFullscreenPlayerDidPresent: PropTypes.func,
  onVideoFullscreenPlayerWillDismiss: PropTypes.func,
  onVideoFullscreenPlayerDidDismiss: PropTypes.func,
  onAdChangedState: PropTypes.func,

  /* Wrapper component */
  source: PropTypes.oneOfType([
    PropTypes.shape({
      uri: PropTypes.string,
      entry: PropTypes.object
    }),
    // Opaque type returned by require('./video.mp4')
    PropTypes.number
  ]),

  resizeMode: PropTypes.string,
  poster: PropTypes.string,
  posterResizeMode: Image.propTypes.resizeMode,
  repatVideo: PropTypes.bool,
  allowsExternalPlayback: PropTypes.bool,
  paused: PropTypes.bool,
  muted: PropTypes.bool,
  volume: PropTypes.number,
  bufferConfig: PropTypes.shape({
    minBufferMs: PropTypes.number,
    maxBufferMs: PropTypes.number,
    bufferForPlaybackMs: PropTypes.number,
    bufferForPlaybackAfterRebufferMs: PropTypes.number
  }),
  stereoPan: PropTypes.number,
  rate: PropTypes.number,
  playInBackground: PropTypes.bool,
  playWhenInactive: PropTypes.bool,
  ignoreSilentSwitch: PropTypes.oneOf(["ignore", "obey"]),
  disableFocus: PropTypes.bool,
  controls: PropTypes.bool,
  audioOnly: PropTypes.bool,
  currentTime: PropTypes.number,
  progressUpdateInterval: PropTypes.number,
  useTextureView: PropTypes.bool,
  onLoadStart: PropTypes.func,
  onLoad: PropTypes.func,
  onBuffer: PropTypes.func,
  onError: PropTypes.func,
  onProgress: PropTypes.func,
  onSeek: PropTypes.func,
  onEnd: PropTypes.func,
  onFullscreenPlayerWillPresent: PropTypes.func,
  onFullscreenPlayerDidPresent: PropTypes.func,
  onFullscreenPlayerWillDismiss: PropTypes.func,
  onFullscreenPlayerDidDismiss: PropTypes.func,
  onReadyForDisplay: PropTypes.func,
  onPlaybackStalled: PropTypes.func,
  onPlaybackResume: PropTypes.func,
  onPlaybackRateChange: PropTypes.func,
  onAudioFocusChanged: PropTypes.func,
  onAudioBecomingNoisy: PropTypes.func,
  onExternalPlaybackChange: PropTypes.func,

  /* Required by react-native */
  scaleX: PropTypes.number,
  scaleY: PropTypes.number,
  translateX: PropTypes.number,
  translateY: PropTypes.number,
  rotation: PropTypes.number,
  ...ViewPropTypes
};
// RCTVideo
// PlayerModule
const Player = requireNativeComponent("PlayerModule");
