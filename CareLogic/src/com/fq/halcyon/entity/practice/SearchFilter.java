package com.fq.halcyon.entity.practice;

import java.util.ArrayList;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.FQLog;

/**
 * 病案和记录筛选时需要的筛选字段
 * @author reason
 *
 */
public class SearchFilter extends HalcyonEntity{
	
	private static final long serialVersionUID = 1L;
	
	/**过滤的种类*/
	public String category;
	
	/**过滤的选项*/
	public ArrayList<FilterItem> items;
	
	
	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public ArrayList<FilterItem> getItems() {
		return items;
	}

	public void setItems(ArrayList<FilterItem> items) {
		this.items = items;
	}

	
	@Override
	public void setAtttributeByjson(JSONObject json) {
//		super.setAtttributeByjson(json);
		category = json.optString("category");
		JSONArray ims = json.optJSONArray("items");
		if(ims != null){
			items = new ArrayList<FilterItem>();
			for(int i = 0; i < ims.length(); i++){
				FilterItem temp = new FilterItem();
				temp.isSelected = false;
//				if(category.equals("记录类型")){
//					temp.itemsName = RecordConstants.getTypeNameByRecordType(Integer.parseInt(ims.optString(i)));
//				}else{
//					temp.itemsName = ims.optString(i);
//				}
				temp.itemsName = ims.optString(i);
				items.add(temp);
			}
		}
		
		checkNull(category);
	}

	@Override
	public JSONObject getJson() {
		JSONObject json = new JSONObject();
		try {
			json.put("category", category);
			if(items != null){
				String[] itemList = new String[items.size()];
				for (int i = 0; i < items.size(); i++) {
					itemList[i] = items.get(i).getItemsName();
				}
				JSONArray arry = new JSONArray(itemList);
				json.put("items", arry);
			}
		} catch (JSONException e) {
			FQLog.i("构建过滤字段出错");
			e.printStackTrace();
		}
		return json;
	}
}
class FilterItem {
	public int indexSection;
	public int getIndexSection() {
		return indexSection;
	}
	public void setIndexSection(int indexSection) {
		this.indexSection = indexSection;
	}
	public int indexRow;
	public int getIndexRow() {
		return indexRow;
	}
	public void setIndexRow(int indexRow) {
		this.indexRow = indexRow;
	}
	public int position;

	public int getPosition() {
		return position;
	}
	public void setPosition(int position) {
		this.position = position;
	}
	public String itemsName;
	public String getItemsName() {
		return itemsName;
	}
	public void setItemsName(String itemsName) {
		this.itemsName = itemsName;
	}
	public boolean isSelected;
	public boolean isSelected() {
		return isSelected;
	}
	public void setSelected(boolean isSelected) {
		this.isSelected = isSelected;
	}
}