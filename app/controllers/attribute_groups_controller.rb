#encoding: utf-8
#author cway 2013-07-12

class AttributeGroupsController < ApplicationController
  
  # /attribute_groups/get_attributes 
  def get_attributes 
    type                                                          = params[:type]
    attribute_set_id                                              = params[:attribute_set_id]
    attributes_list                                               = type == "inner" ? get_inner_attributes( attribute_set_id ) : get_other_attributes( attribute_set_id )

    respond_to do |format|
      format.html  
      format.json { render :json => attributes_list } 
    end
  end
  

  private
  def get_inner_attributes( attribute_set_id )
    attributes_list                                             = Array.new;
    group_list                                                  = Hash.new;
    attributes_records                                          = AttributeGroup.group_inner_attributes( attribute_set_id )
      
    attributes_records.each do |attribute|
      unless group_list.has_key? attribute.attribute_group_name
        group_list[attribute.attribute_group_name]              = Hash.new
        group_list[attribute.attribute_group_name]["attr"]      = { "id" => attribute.attribute_group_id, "rel" => "system_group" }
        group_list[attribute.attribute_group_name]["state"]     = "open"
        group_list[attribute.attribute_group_name]["data"]      = attribute.attribute_group_name
        group_list[attribute.attribute_group_name]["children"]  = Array.new
      end
      attribute_node_rel                                        = attribute.is_required == 0 ? "common_attribute"  : "system_attribute"
      attribute_node                                            = { "attr" => { "id" => attribute.attribute_id, "rel" => attribute_node_rel }, "data" => attribute.attribute_code }
      group_list[attribute.attribute_group_name]["children"].push( attribute_node )
    end
    
    group_list.each do |group_name, group|
      attributes_list << group 
    end
    attributes_list
  end

  def get_other_attributes( attribute_set_id )
    attributes_list                                             = Array.new;
    group_list                                                  = Hash.new;
    group_list["attr"]                                          = { "id" => 0, "rel" => "undefine_group" }
    group_list["state"]                                         = "open"
    group_list["data"]                                          = ""
    group_list["children"]                                      = Array.new
    entity_type_id                                              = params[:entity_type_id]
    attributes_records                                          = AttributeGroup.out_of_group_attributes( entity_type_id, attribute_set_id )
      
    attributes_records.each do |attribute|
      group_list["children"].push({ "attr" => { "id" => attribute.attribute_id, "rel" => "common_attribute" }, "data" => attribute.attribute_code })
    end
      
    attributes_list << group_list
  end
end
