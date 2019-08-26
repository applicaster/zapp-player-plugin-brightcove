import ResolveAssetSource from "react-native/Libraries/Image/resolveAssetSource";


export const stringsOnlyObject = obj => {
    const strObj = {};
    Object.keys(obj).forEach(x => {
        strObj[x] = this.toTypeString(obj[x]);
    });

    return strObj;
};

export const toTypeString = obj => {
    switch (typeof obj) {
        case "object":
            return x instanceof Date ? x.toISOString() : JSON.stringify(x); // object, null
        case "undefined":
            return "";
        default:
            // boolean, number, string
            return x.toString();
    }
};

export const assetsFromSource = source => {
    let asset = ResolveAssetSource(source) || {};

    let uri = source.uri || "";
    if (uri && uri.match(/^\//)) {
        uri = `file://${uri}`;
    }

    const isNetwork = !!(uri && uri.match(/^https?:/));
    const isAsset = !!(
        uri &&
        uri.match(/^(assets-library|ipod-library|file|content|ms-appx|ms-appdata):/)
    );

    return {
        uri,
        isNetwork,
        isAsset,
        type: asset.type || "",
        mainVer: asset.mainVer || 0,
        patchVer: asset.patchVer || 0,
        requestHeaders: asset.headers ? stringsOnlyObject(asset.headers) : {}
    };
};
