import React, {Component} from 'react';
import VideoPlayer from "./src/Components/VideoPlayer";
import {
    AlertIOS,
    StyleSheet,
    View
} from "react-native";

class App extends Component {
    constructor() {
        console.log('constructor');
        super();
        this.onLoad = this.onLoad.bind(this);
        // this.onProgress = this.onProgress.bind(this);
        // this.onBuffer = this.onBuffer.bind(this);
    }

    state = {
        rate: 1,
        volume: 1,
        muted: false,
        duration: 0.0,
        currentTime: 0.0,
        controls: false,
        paused: false,
        skin: "custom",
        ignoreSilentSwitch: null,
        isBuffering: false
    };

    onLoad(data) {
        this.setState({ duration: data.duration });
    }

    onEnd() {
        AlertIOS.alert("Done!");
    }

    render() {
        console.log(this.props.onEnd);
        const videoStyle = styles.fullScreen;
        return (
            <View style={styles.container}>
                <View style={styles.fullScreen}>
                    <VideoPlayer
                        source={this.props.source}
                        style={videoStyle}
                        rate={this.state.rate}
                        paused={this.state.paused}
                        volume={this.state.volume}
                        muted={this.state.muted}
                        onLoad={this.onLoad}
                        onEnd={this.onEnd}
                        // controls={this.state.controls}
                    />
                </View>
            </View>
        );
    }
}

const styles = StyleSheet.create({
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
    controls: {
        backgroundColor: "transparent",
        borderRadius: 5,
        position: "absolute",
        bottom: 44,
        left: 4,
        right: 4
    },
    progress: {
        flex: 1,
        flexDirection: "row",
        borderRadius: 3,
        overflow: "hidden"
    },
    innerProgressCompleted: {
        height: 20,
        backgroundColor: "#cccccc"
    },
    innerProgressRemaining: {
        height: 20,
        backgroundColor: "#2C2C2C"
    },
    generalControls: {
        flex: 1,
        flexDirection: "row",
        overflow: "hidden",
        paddingBottom: 10
    },
    skinControl: {
        flex: 1,
        flexDirection: "row",
        justifyContent: "center"
    },
    rateControl: {
        flex: 1,
        flexDirection: "row",
        justifyContent: "center"
    },
    volumeControl: {
        flex: 1,
        flexDirection: "row",
        justifyContent: "center"
    },
    resizeModeControl: {
        flex: 1,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center"
    },
    ignoreSilentSwitchControl: {
        flex: 1,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center"
    },
    controlOption: {
        alignSelf: "center",
        fontSize: 11,
        color: "white",
        paddingLeft: 2,
        paddingRight: 2,
        lineHeight: 12
    },
    nativeVideoControls: {
        top: 184,
        height: 300
    }
});

export default App;
