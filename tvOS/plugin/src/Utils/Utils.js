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
