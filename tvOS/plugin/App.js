import React, {Component, Fragment} from 'react';
import {
    AlertIOS,
    StyleSheet,
    Text,
    requireNativeComponent,
    View,
    ActivityIndicator
} from "react-native";

const Player = requireNativeComponent("PlayerModule");

export default class App extends Component {

    constructor(props) {
        super(props);

        this.state = {
            isLoading: null,
            isError: false
        };
    }

    setNativeProps(nativeProps) {
        this._root.setNativeProps(nativeProps);
    }

    _assignRoot = component => {
        this._root = component;
    };

    _onLoadStart = () => {
        this.setState({
            isLoading: true
        });
    };

    _onLoad = () => {
        this.setState({
            isLoading: false
        });
    };

    _onError = () => {
        this.setState({
            isError: true
        });
    };

    _onSeek = event => {
        if (this.props.onSeek) {
            this.props.onSeek(event.nativeEvent);
        }
    };

    _onEnd = event => {
        if (this.props.onEnd) {
            this.props.onEnd(event.nativeEvent);
        }
    };

    renderErrorMessage() {
        return (
            <View style={styles.errorContainer}>
                <View style={styles.container}>
                    <Text style={styles.errorMessage}>Oops, something went wrong...</Text>
                </View>
            </View>
        )
    }

    renderPlayer(nativeProps) {
        return (
            <Fragment>
                <Player ref={this._assignRoot} {...nativeProps} />
            </Fragment>
        )
    }

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
                onVideoSeek: this._onSeek,
                onVideoEnd: this._onEnd,
            }
        };

       if (this.state.isError) {
           return (
               this.renderErrorMessage()
           )
       }

       return (
           this.renderPlayer(nativeProps)
       )
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
    }
});
