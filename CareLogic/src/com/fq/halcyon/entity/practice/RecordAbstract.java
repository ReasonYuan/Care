package com.fq.halcyon.entity.practice;

import java.util.ArrayList;

import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 病历记录的摘要类，存放一个记录的摘要信息，便于显示及查看
 * @author reason
 *
 */
public class RecordAbstract extends RecordData{

	private static final long serialVersionUID = 1L;

	/**记录的类型，分为一般和体检*/
	private int recordCategory;
	
	/**病历记录的类型*/
	private int recordType;
	
	/**病历记录的摘要信息*/
	private String infoAbstract;
	
	/**病历记录的识别状态*/
	private int recStatus;
	
	/**病历记录的记录详情id*/
	private int recordInfoId;
	
	/**病历记录的id*/
	private int recordItemId;
	
	/**病历记录的识别完成时间*/
	private String dealTime;
	
	/**病历记录归档时间*/
	private String fileTime;
	
	/**病历记录的名字*/
	private String recordItemName;
	
	/**记录显示的类型名字*/
	private String typeName;
	
	/**记录所属病案的名称，用于从记录详情返回到病案下所有记录列表*/
	private String patientName;
//	/**病案删除时间，如果该病案被删除，则有此参数*/
//	private String deleteTime;
	
//	/**这份记录是不是选中*/
//	private boolean isSelected;
	
	private ArrayList<Integer> imgIds;
	
	
	public int getRecordType() {
		return recordType;
	}

	public void setRecordType(int recordType) {
		this.recordType = recordType;
	}

	public String getInfoAbstract() {
		return infoAbstract;
	}

	public void setInfoAbstract(String infoAbstract) {
		this.infoAbstract = infoAbstract;
	}

	public int getRecStatus() {
		return recStatus;
	}

	public void setRecStatus(int recStatus) {
		this.recStatus = recStatus;
	}

	public int getRecordInfoId() {
		return recordInfoId;
	}

	public void setRecordInfoId(int itemInfoId) {
		this.recordInfoId = itemInfoId;
	}

	public int getRecordItemId() {
		return recordItemId;
	}

	public void setRecordItemId(int recordItemId) {
		this.recordItemId = recordItemId;
	}
	
	public String getDealTime() {
		return dealTime;
	}

	public void setDealTime(String dealTime) {
		this.dealTime = dealTime;
	}
//	
//	public String getDeleteTime() {
//		return deleteTime;
//	}
//
//	public void setDeleteTime(String deleteTime) {
//		this.deleteTime = deleteTime;
//	}
	
	public String getFileTime() {
		return fileTime;
	}

	public void setFileTime(String filetime) {
		this.fileTime = filetime;
	}

	public void setRecordItemName(String name){
		this.recordItemName = name;
	}
	
	public String getRecordItemName(){
		return recordItemName;
	}
	
	public String getTypeName(){
		return typeName;
	}
	
	public String getPatientName(){
		return patientName;
	}
	
	public void setImgIds(ArrayList<Integer> ids){
		imgIds = ids;
	}
	
	public ArrayList<Integer> getImgIds(){
		return imgIds;
	}
	
	public int getRecordCagegory(){
		return recordCategory;
	}
	
	/**deal的转化形式，用于显示列表item上的记录时间，格式：yyyy年MM月dd日*/
	private String deal2Time;
	public String getDeal2Time(){
		if(deal2Time == null){
			if("".equals(dealTime)){
				deal2Time = "";
			}else{
				deal2Time = TimeFormatUtils.changeDealTime(dealTime);
			}
		}
		return deal2Time;
	}
	
	/**得到记录下的图片*/
	public ArrayList<PhotoRecord> getImgPhotos(){
		ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();
		if(imgIds == null || imgIds.size() == 0)return photos;
		
		for(int i = 0; i < imgIds.size(); i++){
        	PhotoRecord photo = new PhotoRecord();
        	photo.setImageId(imgIds.get(i));
        	photos.add(photo);
        }
		return photos;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		
		recordCategory = json.optInt("record_category", RecordConstants.PATIENT_CATEGORY_NORMAL);
		recordType = json.optInt("record_type");
		recordItemName = json.optString("record_item_name");
		infoAbstract = json.optString("info_abstract", "");
		recStatus = json.optInt("rec_status");
		recordInfoId = json.optInt("record_info_id");	
		recordItemId = json.optInt("record_item_id");
		fileTime = json.optString("file_time");
		deleteTime = json.optString("deleted_at");
		dealTime = json.optString("deal_time");
		patientName = json.optString("patient_name");
		typeName = json.optString("type_name");
		if("".equals(typeName) || "null".equals(typeName)){
			typeName = RecordConstants.getTypeNameByRecordType(recordType);
		}
		
		
		//将“null”转为""
		infoAbstract = checkNull(infoAbstract);
		deleteTime = checkNull(deleteTime);
		fileTime = checkNull(fileTime);
		deleteTime = checkNull(deleteTime);
		dealTime = checkNull(dealTime);
		patientName = checkNull(patientName);
		recordItemName = checkNull(recordItemName);
		
		JSONArray imgs = json.optJSONArray("images");
		if(imgs != null){
			imgIds = new ArrayList<Integer>();
			for(int i = 0; i < imgs.length(); i++){
				imgIds.add(imgs.optInt(i));
			}
		}
	}
	
	@Override
	public JSONObject getJson() {
		JSONObject json = new JSONObject();
		try{
			json.put("record_type", recordType);
			json.put("record_item_name", recordItemName);
			json.put("info_abstract", infoAbstract);
			json.put("rec_status", recStatus);
			json.put("record_info_id", recordInfoId);
			json.put("record_item_id", recordItemId);
			json.put("file_time", fileTime);
			json.put("deal_time", dealTime);
			json.put("type_name", typeName);
			json.put("patient_name", patientName);
			if(imgIds != null){
				JSONArray imgs = new JSONArray(imgIds);
				json.put("images", imgs);
			}
		}catch(Exception e){
			FQLog.i("构建病历记录json数据出错");
			e.printStackTrace();
		}
		return json;
	}
	
	
}
