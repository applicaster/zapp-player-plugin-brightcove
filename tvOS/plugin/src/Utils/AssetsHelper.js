import ResolveAssetSource from "react-native/Libraries/Image/resolveAssetSource";
import { stringsOnlyObject } from "./Utils";
import VideoResizeMapping from "../Helpers/VideoResizeMapping";

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

export const resizeModeFromMapping = (resizeModeFromProps, nativeConstants) => {
  let {
    ScaleToFill,
    ScaleAspectFill,
    ScaleAspectFit,
    ScaleNone
  } = nativeConstants;

  let resizeMode;
  if (resizeModeFromProps === VideoResizeMapping.scaleToFill) {
    resizeMode = ScaleToFill;
  } else if (resizeModeFromProps === VideoResizeMapping.scaleAspectFit) {
    resizeMode = ScaleAspectFit;
  } else if (resizeModeFromProps === VideoResizeMapping.scaleAspectFill) {
    resizeMode = ScaleAspectFill;
  } else {
    resizeMode = ScaleNone;
  }
  return resizeMode;
};
