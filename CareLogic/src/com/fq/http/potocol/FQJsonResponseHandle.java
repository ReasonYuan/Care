package com.fq.http.potocol;

import com.fq.lib.json.JSONObject;
import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "FQJsonResponseHandle.h"
]-*/
@ObjectiveCName("FQJsonResponseHandle")
public abstract class FQJsonResponseHandle extends FQBinaryResponseHandle{

	@Override
	public void handleBinaryData(byte[] data) {
		try {
			JSONObject json = new  JSONObject(new String(data,"UTF-8"));
			handleJson(json);
		} catch (Exception e) {
			e.printStackTrace();
			onError(0,e);
		}
	}
	
	public abstract void handleJson(JSONObject json);

}
