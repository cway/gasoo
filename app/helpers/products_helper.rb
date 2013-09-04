#encoding: utf-8
module ProductsHelper

   def get_attribute_input( attribute, product )
     input_str        =  ""
     if product['configurable_attributes']
       if product['configurable_attributes'].include?( attribute.attribute_id )
         return input_str
       end
     end     

     input_str         =  "<div class=\"control-group\"><label class=\"control-label\" for=\"#{attribute.attribute_code}\">#{attribute.frontend_label}</label><div class=\"controls\">"

     case attribute.frontend_input 
     when "text"
     	input_str     += "<input type=\"text\" name=\"attributes[#{attribute.attribute_code}]\" class = \"input-xlarge attribute_value\" id =\"#{attribute.attribute_code}\" />"
     when "select"
     	input_str     += "<select id=\"#{attribute.attribute_code}\" name=\"attributes[#{attribute.attribute_code}]\" class=\"attribute_value\" data-rel=\"chosen\">"
     	attribute.options.each do |option|
     		input_str += "<option value=\"#{option.option_id}\">#{option.value}</option>"
        end
        input_str     += "</select>"
     when "textarea"
     	input_str     += "<textarea class=\"cleditor attribute_value\" name=\"attributes[#{attribute.attribute_code}]\" id=\"#{attribute.attribute_code}\" rows=\"3\"></textarea>"
     when "price"
     	input_str     += "<div class=\"input-prepend input-append\"><span class=\"add-on\">￥</span><input name=\"attributes[#{attribute.attribute_code}]\" id=\"#{attribute.attribute_code}\" class=\"attribute_value\" size=\"16\" type=\"text\" ></div>"
     when "image"
     	input_str     += "<button id=\"image-management\" class=\"btn btn-large btn-primary btn-round\">选择图片</button><table class=\"table table-striped\"><thead><tr><th>缩略图</th><th>图片地址</th><th></th></tr></thead><tbody id=\"product_images_tbody\"></tbody></table>"
     end

     input_str       += "</div></div>"      
     input_str   
   end

   def configurable_tab_title( product )
     unless product.has_key? 'configurable_attributes'
       return
     end
     
     "<li><a href=\"#configurable_attributes_tab\" id=\"configurable_attributes_tab_title\">配置选项</a></li>"
   end

   def configurable_tab_content( product )
     unless product.has_key? 'configurable_attributes'
       return 
     end  

     configurable_str  = "<div class=\"tab-pane\" id=\"configurable_attributes_tab\">"
     configurable_str += "<div class=\"row-fluid sortable\"><div class=\"box span12\"><div class=\"box-header well\" data-original-title><h2>创建单个商品</h2></div><div class=\"box-content\"><table class=\"table table-bordered table-striped table-condensed\"><thead></thead><tbody id=\"simple_products_tbody\"></tbody></table><div class=\"pagination pagination-centered\"><button id=\"add-simple-product\" class=\"btn\">创建商品</button></div></div></div><!--/span--></div><!--/row-->"
     configurable_str += "<div class=\"row-fluid sortable\"><div class=\"box span12\"><div class=\"box-header well\" data-original-title><h2>选择已有商品</h2></div><div class=\"box-content\"><table class=\"table table-striped table-bordered bootstrap-datatable datatable\"><thead><tr><th></th><th>名称</th><th>sku</th><th>价格</th><th>库存</th></tr></thead><tbody id=\"exists_products_tbody\">"

     attribute_set_id            = product['attribute_set_id'].to_i
     type_id                     = ApplicationController::SIMPLE_PRODUCT_ID
     conditions                  = { :attribute_set_id => attribute_set_id, :type_id => type_id }
     products                    = Product.select("entity_id").where( conditions )
     ids                         = Array.new
     products.each do |product|
       ids.push( product.entity_id )
     end

     attribute_values                               = Product.get_simple_products_attributes( ids )
     products.each_with_index do |product, index|
       products[index].product_attributes           =   Hash.new
       products[index].product_attributes["name"]   = attribute_values[:name][product.entity_id]
       products[index].product_attributes["sku"]    = attribute_values[:sku][product.entity_id]
       products[index].product_attributes["price"]  = attribute_values[:price][product.entity_id]
       products[index].product_attributes["qty"]    = attribute_values[:qty][product.entity_id]
     end
  
     if product['configurable_children']
       products.each do |tmp_product|
         configurable_str         += "<tr><td class='center'><div class='input-prepend input-append'><input type=\"checkbox\" ";
         if product['configurable_children'].include? (tmp_product.entity_id)
           configurable_str       += "checked=checked "
         end
         configurable_str         +=  "name=\"selected_simple_products\" value=" + tmp_product.entity_id.to_s + " ></div></td><td class='center'>" + tmp_product.product_attributes['name'] + "</td><td class='center'>" + tmp_product.product_attributes['sku'] + "</td><td class='center'>" + tmp_product.product_attributes['price'].to_s + "</td><td class='center'>" + tmp_product.product_attributes['qty'].to_s + "</td></tr>"

       end
     end
     configurable_str           += "</tbody></table></div></div><!--/span--></div><!--/row-->"
     configurable_str           += "</div>"
     configurable_str
   end
end
