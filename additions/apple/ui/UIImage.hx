	static public function imageToJPEG(image:UIImage, quality:Float):Bytes
	{
		return BaseCode64.decodeBytesData(uiimage_imageToBase64JPEG(image.basisID, quality));
	}
	private static var uiimage_imageToBase64JPEG = Lib.load ("basis", "uiimage_imageToBase64JPEG", 2);
	
	static public function imageFromJPEG(bytes:Bytes):UIImage
	{
		var data:String = BaseCode64.enocdeBytesData(bytes.getData());
		var imageID:String = uiimage_imageFromBase64JPEG(data, data.length);
		return cast(BasisApplication.instance.objectManager.getObject(imageID), UIImage);
	}
	private static var uiimage_imageFromBase64JPEG = Lib.load ("basis", "uiimage_imageFromBase64JPEG", 2);