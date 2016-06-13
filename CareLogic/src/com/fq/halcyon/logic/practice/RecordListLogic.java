package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.StrDataComparator;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 获取病案下病历记录接口的逻辑
 * @author reason
 */
public class RecordListLogic {

	/**要查询的记录类型，一般类型*/
	public static final int RECORD_KIND_NORMAL = 1;
	
	/**要查询的记录类型，体检类型*/
	public static final int RECORD_KIND_MEDICAL = 3;
	
	@Weak
	private RecordListCallBack mCallback;
	
	/**
	 * 获得记录列表的接口逻辑的构造方法
	 * @param callback 接口访问完后的回调
	 */
	public RecordListLogic(RecordListCallBack callback){
		mCallback = callback;
	}
	
	/**
	 * 加载病案下得病历记录列表,包括普通的入院、门诊记录和体检记录
	 * @param patientId 病案的id
	 * @param recordType 想要获取的病历记录的类型，为0表示所有类型
	 * @param page 列表的第几页
	 * @param pageSize 每页列表的记录条数，为0时默认为5条
	 */
	public void loadRecordList(int patientId,int recordType,int page,int pageSize){
		loadRecordList(patientId, recordType, page, pageSize,0);
	}
	
	/**
	 * 加载病案下得病历记录列表
	 * @param patientId 病案的id
	 * @param recordType 想要获取的病历记录的类型，为0表示所有类型
	 * @param page 列表的第几页
	 * @param pageSize 每页列表的记录条数，为0时默认为5条
	 * @param recordKind 需要获取的记录类型。不传查询所有，1:住院记录， 3：体检记录
	 */
	public void loadRecordList(int patientId,int recordType,int page,int pageSize,int recordKind){
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			params.put("patient_id", patientId);
			if(recordType > 0)params.put("record_type", recordType);//record_type不传表示全部类型
			params.put("page", page);
			params.put("page_size", pageSize == 0?5:pageSize);
			if(recordKind != 0)params.put("record_kind", recordKind);
		}catch(Exception e){
			FQLog.i("构造获得病案下病历记录列表请求的参数出错");
			e.printStackTrace();
		}

		String url = UriConstants.Conn.URL_PUB + "/record/patient/get_patient_items.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallback.error(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
//                    JSONObject jsobj = (JSONObject)results;
//                    String patientName = jsobj.optString("patient_name");
                    
					JSONArray array = (JSONArray)results;//jsobj.optJSONArray("record_items");
					
					ArrayList<String> keys = new ArrayList<String>();
					HashMap<String, ArrayList<RecordAbstract>> map = new HashMap<String, ArrayList<RecordAbstract>>();
					
					for(int i = 0; i < array.length(); i++){
						JSONObject json = array.optJSONObject(i);
						RecordAbstract record = new RecordAbstract();
						record.setAtttributeByjson(json);
						
                        String time = "";
                        if(!"".equals(record.getDealTime())){
                            try{
                                String temp = record.getDealTime().substring(0, 10);
                                time = temp.substring(0, 10).replaceAll("-", "");
                            }catch(Exception e){
                                FQLog.i("获取病案下病历列表，转换时间格式出错");
                                e.printStackTrace();
                            }
                        }
                        
						ArrayList<RecordAbstract> records = map.get(time);
						if(records == null){
							records = new ArrayList<RecordAbstract>();
							map.put(time, records);
							keys.add(time);
						}
						records.add(record);
					}
					Collections.sort(keys, new StrDataComparator());
					mCallback.recordListCallback(keys, map);
				}else{
					mCallback.error(responseCode, msg);
				}
			}
		});
	}
	
	
	/**
	 * 获得病历记录列表的接口的回调
	 * @author reason
	 */
	public interface RecordListCallBack{
		
		/**
		 * 接口访问成功的回调方法。
		 * @param keys 列表以时间为参照组装成的Map的所有key的集合。
		 * @param map 列表以时间为参照组装成的Map。
		 */
		public void recordListCallback(ArrayList<String> keys,HashMap<String, ArrayList<RecordAbstract>> map);
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void error(int code,String msg);
	}
	
}
