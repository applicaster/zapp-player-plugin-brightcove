import React, { Component } from 'react';
import {
    StyleSheet,
    requireNativeComponent
} from "react-native";

const Player = requireNativeComponent("PlayerModule");

export default class App extends Component {

    constructor(props) {
        super(props);
    }

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

    _onEnd = event => {
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
                onVideoLoadStart: this._onLoadStart,
                onVideoLoad: this._onLoad,
                onVideoError: this._onError,
                onVideoProgress: this._onProgress,
                onVideoEnd: this._onEnd,
            }
        };

        return <Player {...nativeProps} />
    }
}

const styles = StyleSheet.create({
    base: {
        overflow: "hidden"
    },
    container: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "black"
    },
    fullScreen: {
        position: "absolute",
        top: 0,
        left: 0,
        bottom: 0,
        right: 0
    }
});
