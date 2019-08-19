import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  requireNativeComponent,
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

  // setNativeProps(nativeProps) {
  //   this._root.setNativeProps(nativeProps);
  // }

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

  render() {
    const { source } = this.props;
    console.log(this.props);

    const nativeProps = {
      ...this.props,
      ...{
        style: styles.base,
        src: source,
        onLoadStart: this._onLoadStart,
        onLoad: this._onLoad,
        onSeek: this._onSeek,
        onEnd: this._onEnd
      }
    };
    return <Player {...nativeProps}/>;
    // return (
    //   <React.Fragment>
    //     <Player ref={this._assignRoot} {...nativeProps} />
    //     {this.props.poster && this.state.showPoster && (
    //       <View style={nativeProps.style}>
    //         <Image style={posterStyle} source={{ uri: this.props.poster }} />
    //       </View>
    //     )}
    //   </React.Fragment>
    // );
  }
}

const Player = requireNativeComponent("PlayerModule");
