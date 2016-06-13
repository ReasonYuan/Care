package com.fq.halcyon.logic.practice;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class DelMemberLogic {
	
	@Weak
	private DelMemberCallBack mCallBack;
	
	public DelMemberLogic(DelMemberCallBack callBack) {
		this.mCallBack = callBack;
	}
	
	public interface DelMemberCallBack {
		public void delMemberSuccess(int patientId, String msg);
		public void delMemberError(int errorCode,String msg);
	}
	
	/**
	 * 删除成员
	 * @param patientId 成员ID
	 */
	public void delMemberLogic(final int patientId){
		String url = UriConstants.Conn.URL_PUB + "/home/remove_member.do";
		JSONObject params = JsonHelper.createUserIdJson();
		try {
			params.put("patient_id", patientId);
		} catch (JSONException e) {
			mCallBack.delMemberError(1, e.getMessage());
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(url, new FQHttpParams(params),  API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mCallBack.delMemberError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					mCallBack.delMemberSuccess(patientId, msg);
				}else{
					mCallBack.delMemberError(responseCode, msg);
				}
			}
		});
	}
}
