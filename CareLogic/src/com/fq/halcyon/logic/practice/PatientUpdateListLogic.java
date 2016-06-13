package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 获取病案列表(按对病案修改的时间排序)
 * @author reason
 */
public class PatientUpdateListLogic {

	/**
	 * 获取病案列表的数据回调
	 */
	@Weak
	private PatientListCallback mCallback;
	
//	@Weak
//	private DiagnoseCallback mDiagnoseCallback;
	
	
//	public PatientUpdateListLogic(DiagnoseCallback call){
//		mDiagnoseCallback = call;
//	}
	
	
	public PatientUpdateListLogic(PatientListCallback call){
		mCallback = call;
	}
	
	/**
	 * 获取病案列表
	 * 如果pageSize为0，默认20条一页
	 */
	public void requestPatientList(final int page,int pageSize,final boolean isMapList){
		JSONObject params = JsonHelper.createUserIdJson();

		try{
			params.put("page", page);
			params.put("page_size", pageSize == 0?20:pageSize);
		}catch (Exception e){
			FQLog.i("构建用户病案列表请求参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/patient/get_recent_patients.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mCallback.loadPatientError(code, Constants.Msg.NET_ERROR);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					if(isMapList){
						HashMap<String, ArrayList<PatientAbstract>> patientMap = createPatientMapByJson((JSONArray)results);
						mCallback.loadPatientSuccess(patientMap);
					}else{
						ArrayList<PatientAbstract> patientList = createPatientListByJson((JSONArray)results);
						((PatientLineListCallback)mCallback).loadPatientLineListSuccess(patientList);
					}
				}else{
					mCallback.loadPatientError(responseCode, msg);
				}
			}
		});
	}
	
	
	/**
	 * 获取病案列表(树型)
	 * 如果pageSize为0，默认20条一页
	 */
	public void requestPatientList(final int page,int pageSize){
		requestPatientList(page, pageSize, true);
	}
	
	/**
	 * 传入的搜索参数不能为空[],如果size为0则直接返回
	 * @param page
	 * @param pageSize
	 * @param diagnoseNames 搜索参数数组，不能为空，没有内容
	 */
	public void requestDiagnose(int page,int pageSize,ArrayList<String> diagnoseNames){
		if(diagnoseNames == null ||diagnoseNames.size() == 0)return;
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			params.put("page", page);
			params.put("page_size", pageSize == 0? 20:pageSize);
			params.put("diagnose_name",new JSONArray(diagnoseNames));
		}catch(Exception e){
			FQLog.i("构建首页Insight图表联动数据出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/patient/get_patient_by_diagnose_name.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				mCallback.loadPatientError(code, Constants.Msg.NET_ERROR);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					HashMap<String, ArrayList<PatientAbstract>> patientMap = createPatientMapByJson((JSONArray)results);
					mCallback.loadPatientSuccess(patientMap);
				}else{
					mCallback.loadPatientError(responseCode, msg);
				}	
			}
		});
	}
	
	/**
	 * 将得到的JsonArray按时间组装才PatientAbstract的树型结构
	 * @param results
	 * @return
	 */
	private HashMap<String, ArrayList<PatientAbstract>> createPatientMapByJson(JSONArray results){
		HashMap<String, ArrayList<PatientAbstract>> patientMap = new HashMap<String, ArrayList<PatientAbstract>>();
		
//		JSONArray patArray = (JSONArray)results;
		long currentZeroTime = TimeFormatUtils.getCurrentZeroTime();
		for(int i = 0; i < results.length(); i++){
			JSONObject json = results.optJSONObject(i);
			PatientAbstract patient = new PatientAbstract();
			patient.setAtttributeByjson(json);
			
			
			long mills = TimeFormatUtils.getTimeMillisByDateWithSeconds(patient.getUpdateTime());
			String time = TimeFormatUtils.getHeadByTime(currentZeroTime, mills);
			
			ArrayList<PatientAbstract> patients = patientMap.get(time);
			if(patients == null){
				patients = new ArrayList<PatientAbstract>();
				patientMap.put(time, patients);
			}
			patients.add(patient);
		}
		return patientMap;
	}
	
	
	/**
	 * 将得到的JsonArray按时间组装才PatientAbstract的线型结构
	 * @param results
	 * @return
	 */
	private ArrayList<PatientAbstract> createPatientListByJson(JSONArray results){
		ArrayList<PatientAbstract> patientList = new ArrayList<PatientAbstract>();
		for(int i = 0; i < results.length(); i++){
			JSONObject json = results.optJSONObject(i);
			PatientAbstract patient = new PatientAbstract();
			patient.setAtttributeByjson(json);
			patientList.add(patient);
		}
		return patientList;
	}
	
	
	/**
	 * 获取病案列表的对调
	 * @author reason
	 */
	public interface PatientListCallback{
		
		
		/**
		 * 加载病案列表成功
		 * @param key 病案列表分组的Group Head
		 * @param map 病案列表的树形结构
		 */
		public void loadPatientSuccess(HashMap<String, ArrayList<PatientAbstract>> map);
		
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void loadPatientError(int code, String msg);
	}
	
//	/**
//	 * 获取病案列表的对调
//	 * @author reason
//	 */
//	public interface DiagnoseCallback{
//		
//		
//		/**
//		 * 加载病案列表成功
//		 * @param key 病案列表分组的Group Head
//		 * @param map 病案列表的树形结构
//		 */
//		public void diagnoseDataSuccess(HashMap<String, ArrayList<PatientAbstract>> map);
//		
//		
//		/**
//		 * 关于请求诊断的错误回调(包括访问出错和服务器出错)。
//		 * @param code 错误信息的代号
//		 * @param msg  错误信息的内容
//		 */
//		public void diagnoseDataError(int code, String msg);
//	}
	
	
	/**
	 * 获取病案列表(树型)的回调
	 * @author reason
	 */
	public interface PatientLineListCallback extends PatientListCallback{
		/**
		 * 加载病案列表成功
		 * @param key 病案列表分组的Group Head
		 * @param map 病案列表的树形结构
		 */
		public void loadPatientLineListSuccess(ArrayList<PatientAbstract> list);
	}
}
