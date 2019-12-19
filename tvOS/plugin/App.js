import React, { Component } from 'react';
import {
    StyleSheet,
    requireNativeComponent,
    TouchableOpacity
} from "react-native";

import { ErrorDisplay } from '@applicaster/zapp-react-native-tvos-ui-components/Components/PlayerWrapper/ErrorDisplay';

const Player = requireNativeComponent("PlayerModule");

export default class App extends Component {

    constructor(props) {
        super(props);

        this.state = {
            isError: null
        }
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
        this.setState({
            isError: event.nativeEvent
        });
        this.props.onError(event.nativeEvent);
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

        const {
            source
        } = this.props;

        const nativeProps = {
            ...this.props,
            ...{
                style: styles.base,
                src: source,
                entry: source.entry,
                onVideoLoadStart: this._onLoadStart,
                onVideoLoad: this._onLoad,
                onVideoError: this._onError,
                onVideoProgress: this._onProgress,
                onVideoEnd: this._onEnd,
            }
        };

        if (this.state.isError) {
            return (
                <TouchableOpacity onPress={this._onEnd}>
                    <ErrorDisplay />
                </TouchableOpacity>
            )
        }

        return <Player {...nativeProps} />
    }
}

const styles = StyleSheet.create({
    base: {
        overflow: "hidden"
    }
});
