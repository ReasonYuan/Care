package com.fq.http.potocol;

import com.fq.http.async.FQHeader;
import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "FQHttpResponseHandle.h"
]-*/
@ObjectiveCName("FQHttpResponseHandle")
public interface FQHttpResponseHandle {
	
	public void onError(int code,Throwable e);
	public void handleResponse(byte[] data);
	/**
	 * 返回发起请求时应该设置的http headers
	 * @return
	 */
    public FQHeader[] getRequestHeaders();
    /**
     * 返回该请求的headers
     * @param headers
     */
    public void setRequestHeaders(FQHeader[] headers);
}
