import React, {Component, Fragment} from 'react';
import {
    StyleSheet,
    requireNativeComponent
} from "react-native";

import { ErrorDisplay } from '@applicaster/zapp-react-native-tvos-ui-components/Components/PlayerWrapper/ErrorDisplay';

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

    render() {
        const { source: src } = this.props;

        const nativeProps = {
            ...this.props,
            ...{
                style: styles.base,
                src: src,
                onVideoLoadStart: this._onLoadStart,
                onVideoLoad: this._onLoad,
                onVideoError: this._onError,
                onVideoProgress: this._onProgress,
                onVideoEnd: this._onEnd,
                onVideoFullscreenPlayerWillPresent: this._onFullscreenPlayerWillPresent,
                onVideoFullscreenPlayerDidPresent: this._onFullscreenPlayerDidPresent,
                onVideoFullscreenPlayerWillDismiss: this._onFullscreenPlayerWillDismiss,
                onVideoFullscreenPlayerDidDismiss: this._onFullscreenPlayerDidDismiss
            }
        };

        return (
            <Fragment>
                <Player {...nativeProps} />
            </Fragment>
        );
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
    },
    errorContainer: {
        position: "absolute",
        backgroundColor: "black",
        top: 0,
        left: 0,
        bottom: 0,
        right: 0
    },
    errorMessage: {
        fontSize: 48,
        color: 'white'
    },
    loader: {
        position: "absolute",
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.5)'
    }
});
