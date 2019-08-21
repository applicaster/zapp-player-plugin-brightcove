import React, { Component } from "react";
import {
  StyleSheet,
  requireNativeComponent,
  View,
  Image
} from "react-native";

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

  _assignRoot = component => {
      this._root = component;
  };

  _onLoad = event => {
    if (this.props.onLoad) {
      this.props.onLoad(event.nativeEvent);
    }
  };

  _onEnd = event => {
      console.log(event);
    if (this.props.onEnd) {
      this.props.onEnd(event.nativeEvent);
    }
  };

  render() {
    const { source } = this.props;

    const nativeProps = {
      ...this.props,
      ...{
        style: styles.base,
        src: source,
        onVideoLoad: this._onLoad,
        onVideoEnd: this._onEnd
      }
    };
    return (
        <React.Fragment>
            <Player ref={this._assignRoot} {...nativeProps} />
        </React.Fragment>
    );
  }
}

const Player = requireNativeComponent("PlayerModule", VideoPlayer, {
    nativeOnly: {
        src: true,
        seek: true,
        fullscreen: true
    }
});
