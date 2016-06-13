package com.fq.lib;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.lib.tools.UriConstants;

public class UploadImageHelper {
	public void upLoadImg(String path,HalcyonHttpResponseHandle handle){
		HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB+"/pub/upload_images.do", path,handle);
	}
}
