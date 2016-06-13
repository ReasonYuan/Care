package com.fq.halcyon.entity.practice;

import java.util.ArrayList;

import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.FQLog;

/**
 * 病案和记录筛选时请求接口需要的参数类<br/>
 * 由于需要的数据过多，所以单独抽象成一个类
 * @author reason
 *
 */
public class SearchParams{

	/**搜索时不需要服务器返回后面的分类类别*/
	public static final int FILTERS_UNNEED = 0;
	/**搜索时需要服务器返回后面的分类类别*/
	public static final int FILTERS_NEED = 1;
	
	/**返回病案和记录两种*/
	public static final int RESPONSE_ALL = 0;
	/**只返回病案*/
	public static final int RESPONSE_PATIENT = 1;
	/**只返回记录*/
	public static final int RESPONSE_RECORD = 2;
	
//	private static final long serialVersionUID = 1L;
	
	/**是不是需要服务器返回后面的过滤(分类)列表。(0:不需要 1:需要)*/
	private int needFilters;
	
	/**需要返回数据的类型(0:病案和记录  1:只有病案  2:只有记录)*/
	private int responseType;
	
	/**病案id*/
	private int patientId;
	
	/**搜索的关键字*/
	private String key;
	
	/**第几页,从1开始计算*/
	private int page;
	
	/**每页显示的数据数量,病案、记录为各取(默认为5条)*/
	private int pageSize = 5;
	
	/**筛选时的起始时间*/
	private String toData;
	
	/**筛选时的结束时间*/
	private String fromData;
	
	/**需要筛选的关键字*/
	private ArrayList<SearchFilter> filters;

	public int getNeedFilters() {
		return needFilters;
	}

	public void setNeedFilters(int needFilters) {
		this.needFilters = needFilters;
	}
	
	public void setNeedFilters(boolean isNeed) {
		this.needFilters = isNeed?1:0;
	}

	public int getResponseType() {
		return responseType;
	}

	public void setResponseType(int responseType) {
		this.responseType = responseType;
	}

	public int getPagintId() {
		return patientId;
	}

	public void setPagintId(int pagintId) {
		this.patientId = pagintId;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public int getPage() {
		return page;
	}

	public void setPage(int page) {
		this.page = page;
	}

	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	public String getToData() {
		return toData;
	}

	public void setToData(String toData) {
		this.toData = toData;
	}

	public String getFromData() {
		return fromData;
	}

	public void setFromData(String fromData) {
		this.fromData = fromData;
	}

	public ArrayList<SearchFilter> getFilters() {
		return filters;
	}

	public void setFilters(ArrayList<SearchFilter> filters) {
		this.filters = filters;
	}
	
	public JSONObject getSearhParams(){
		JSONObject params = JsonHelper.createUserIdJson();
		
		try {
			params.put("need_filters", needFilters);
			params.put("response_type", responseType);
			params.put("data_filter", key);
			params.put("page", page);
			params.put("page_size", pageSize);
			if(patientId != 0)params.put("patient_id", patientId);
			if(!"".equals(fromData))params.put("from_date", fromData);
			if(!"".equals(toData))params.put("to_date", toData);
			
			if(filters != null){
				JSONArray array = new JSONArray();
				for(int i = 0; i < filters.size(); i++){
					array.put(filters.get(i).getJson());
				}
				params.put("filters", array);
			}
		} catch (JSONException e) {
			FQLog.i("构建搜索接口的请求参数出错");
			e.printStackTrace();
		}
		return params;
	}
}
