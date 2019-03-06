import React from 'react';

export default class Utils {
    static humanFileSize(bytes, si) {
      const thresh = si ? 1000 : 1024;
      if (Math.abs(bytes) < thresh) {
        return `${bytes} B`;
      }
      const units = si
        ? ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
        : ['KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
      let u = -1;
      do {
        bytes /= thresh;
        ++u;
      } while (Math.abs(bytes) >= thresh && u < units.length - 1);
      return `${bytes.toFixed(1)} ${units[u]}`;
    }


    static jsonToElement(type, obj)
    {
      let properties = Object.keys(obj)
                             .filter(k => { if (k=="style" || Array.isArray(obj[k])) return false; return true; })
                             .map(k => ({ [k]: obj[k]}) )
                            .reduce((a, cur) => (Object.assign({}, a, cur)))                            
      let childrenKeys = Object.keys(obj).filter(k => (Array.isArray(obj[k])))
      if ("style" in obj)
      {
        var style = {},
        attributes = obj["style"].split(';');    
        for (var i = 0; i < attributes.length; i++) {
            var entry = attributes[i].split(':');
            var styleKey = (entry.splice(0,1)[0]).trim()
            if (styleKey === "") continue;
            style[styleKey] = entry.join(':');
        }
        properties["style"] = style
      }
      if (childrenKeys.length == 0)
        return React.createElement(type, properties)
      else {
        let children = childrenKeys.map(key => (obj[key].map(childObject => Utils.jsonToElement(key, childObject))))
        return React.createElement(type, properties, children)
      }

    }
  }
  