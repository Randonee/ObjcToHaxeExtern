	static public function imageToJPEG(image:UIImage, quality:Float):Bytes
	{
		return BaseCode64.decodeBytesData(uiimage_imageToBase64JPEG(image.basisID, quality));
	}
	private static var uiimage_imageToBase64JPEG = Lib.load ("basis", "uiimage_imageToBase64JPEG", 2);