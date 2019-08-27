import React, {Component, Fragment} from 'react';
import {
    StyleSheet,
    requireNativeComponent,
    TouchableOpacity,
    BackHandler,
    Text
} from "react-native";

import { ErrorDisplay } from '@applicaster/zapp-react-native-tvos-ui-components/Components/PlayerWrapper/ErrorDisplay';

const Player = requireNativeComponent("PlayerModule");

export default class App extends Component {

    constructor(props) {
        super(props);

        this.state = {
            isLoading: null,
            isError: 'error'
        };

        this._isMounted = false;
    }

    componentDidMount() {
        this._isMounted = true;
    }

    componentWillUnmount() {
        this._isMounted = false;
    }

    setNativeProps(nativeProps) {
        this._root.setNativeProps(nativeProps);
    }

    _assignRoot = component => {
        this._root = component;
    };

    _onLoadStart = () => {
        this._isMounted && this.setState({
            isLoading: true
        });
    };

    _onLoad = () => {
        this._isMounted && this.setState({
            isLoading: false
        });
    };

    _onError = ({error}) => {
        this.setState({
            isError: error.message,
            isLoading: false
        });
    };

    _onEnd = event => {
        console.log(event);
        this._isMounted = false;
        BackHandler.exitApp();
        return true;
    };

    handleBackPress = (event) => {
        console.log(event);
        BackHandler.exitApp();
        return true;
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
                onVideoEnd: this._onEnd,
            }
        };

        if (this.state.isError) {
            return (
                <TouchableOpacity onPress={(event) => this.handleBackPress(event)}>
                    <ErrorDisplay />
                    <Text>Hello</Text>
                </TouchableOpacity>
            )
        }

        return (
            <Fragment>
                <Player
                    ref={this._assignRoot}
                    {...nativeProps}
                />
            </Fragment>
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
