@import <AppKit/CPView.j>
@import "base64.j"

/*
 * Canvas2Image v0.1
 * Copyright (c) 2008 Jacob Seidelin, cupboy@gmail.com
 * MIT License [http://www.opensource.org/licenses/mit-license.php]
 */

/******* Canvas2Image code starts here *******/
var Canvas2Image = (function() {
	var strDownloadMime = "image/octet-stream";

	// sends the generated file to the client
	var saveFile = function(strData) {
		document.location.href = strData;
	}

	// generates a <img> object containing the imagedata
	var makeImageObject = function(strSource) {
		var oImgElement = document.createElement("img");
		oImgElement.src = strSource;
		return oImgElement;
	}

	var scaleCanvas = function(oCanvas, iWidth, iHeight) {
		if (iWidth && iHeight) {
			var oSaveCanvas = document.createElement("canvas");
			oSaveCanvas.width = iWidth;
			oSaveCanvas.height = iHeight;
			oSaveCanvas.style.width = iWidth+"px";
			oSaveCanvas.style.height = iHeight+"px";

			var oSaveCtx = oSaveCanvas.getContext("2d");

			oSaveCtx.drawImage(oCanvas, 0, 0, oCanvas.width, oCanvas.height, 0, 0, iWidth, iWidth);
			return oSaveCanvas;
		}
		return oCanvas;
	}

	return {

		saveAsPNG : function(oCanvas, bReturnImg, iWidth, iHeight) {
			var oScaledCanvas = scaleCanvas(oCanvas, iWidth, iHeight);
			var strData = oScaledCanvas.toDataURL("image/png");
			if (bReturnImg) {
				return makeImageObject(strData);
			} else {
				saveFile(strData.replace("image/png", strDownloadMime));
			}
			return true;
		},

		saveAsJPEG : function(oCanvas, bReturnImg, iWidth, iHeight) {
			var oScaledCanvas = scaleCanvas(oCanvas, iWidth, iHeight);
			var strMime = "image/jpeg";
			var strData = oScaledCanvas.toDataURL(strMime);

			// check if browser actually supports jpeg by looking for the mime type in the data uri.
			// if not, return false
			if (strData.indexOf(strMime) != 5) {
				return false;
			}

			if (bReturnImg) {
				return makeImageObject(strData);
			} else {
				saveFile(strData.replace(strMime, strDownloadMime));
			}
			return true;
		},
	};

})();

/******* Canvas2Image code ends here *******/

@implementation CPView (Export)

- (DOMElement)mergedImageInDataUriScheme
{
    var canvasElements = _DOMElement.getElementsByTagName("canvas"),
        count = canvasElements.length,
        mergedCanvas = nil;

    while (count--)
    {
        var cc = canvasElements[count];

        if (!mergedCanvas)
        {
            mergedCanvas = document.createElement("canvas");
			mergedCanvas.width = cc.width;
			mergedCanvas.height = cc.height;
			mergedCanvas.style.width = cc.width+"px";
			mergedCanvas.style.height = cc.height+"px";
        }

        mergedCanvas.getContext("2d").drawImage(cc, 0, 0);
    }

    var img = Canvas2Image.saveAsJPEG(mergedCanvas, true);
    return img.src;
}

- (CPColor)colorAt:(CPPoint)aPoint
{
    var canvasElements = _DOMElement.getElementsByTagName("canvas");

    var ca = canvasElements[0].getContext("2d").getImageData(aPoint.x, aPoint.y, 1, 1).data;
    var cb = canvasElements[1].getContext("2d").getImageData(aPoint.x, aPoint.y, 1, 1).data;

    var ra = ca[0], rb = cb[0];
    var ga = ca[1], gb = cb[1];
    var ba = ca[2], bb = cb[2];
    var aa = ca[3], ab = cb[3], iaa = 255 - aa;
    var a0 = aa + ab * (255 - aa);

    if (a0 <= 0)
        return [CPColor clearColor];

    var r = MIN(255, (ra * aa + rb * ab * iaa) / a0) / 255.0;
    var g = MIN(255, (ga * aa + gb * ab * iaa) / a0) / 255.0;
    var b = MIN(255, (ba * aa + bb * ab * iaa) / a0) / 255.0;

    return [CPColor colorWithRed:r green:g blue:b alpha:1.0];
}
