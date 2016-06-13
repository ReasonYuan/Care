package com.fq.halcyon.logic.practice;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.MyRelationship;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class AddMemberLogic {

	@Weak
	private AddMemberCallBack mCallBack;
	
	private MyRelationship member;
	private String relName;
	private int mIdentityId;
	
	public AddMemberLogic(AddMemberCallBack callBack) {
		this.mCallBack = callBack;
	}
	
	public interface AddMemberCallBack {
		public void addMemberSuccess(MyRelationship member);
		public void addMemberError(int errorCode,String msg);
	}
	
	/**
	 * 添加成员
	 * @param name  成员名字
	 * @param identityId 成员关系
	 */
	public void addMemberLogic(String name,int identityId){
		String url = UriConstants.Conn.URL_PUB + "/home/add_update_member.do";
		JSONObject params = JsonHelper.createUserIdJson();
		this.relName = name;
		this.mIdentityId = identityId;
		try {
			params.put("name", name);
			params.put("identity_id", identityId);
		} catch (JSONException e) {
			mCallBack.addMemberError(1, e.getMessage());
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(url, new FQHttpParams(params),  API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mCallBack.addMemberError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					JSONObject json = (JSONObject) results;
					member = new MyRelationship();
					member.setRelName(relName);
					member.setIdentityId(mIdentityId);
					member.setPatientId(json.optInt("patient_id"));
					mCallBack.addMemberSuccess(member);
				}else{
					mCallBack.addMemberError(responseCode, msg);
				}
			}
		});
	}
}
