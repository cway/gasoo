function ProductObj( entity )
{
   //entity                   = JSON.parse( obj_str );
   for(var entity_code in entity)
   {
     this[entity_code]                   = entity[entity_code]; 
   } 
  
   console.log( this );
   return
}

ProductObj.prototype.AddImage = function( image_url )
{
   if( false == this.hasOwnProperty( "image" ) )
   {
      this.image           = new Array();
   }
   else if( jQuery.inArray( image_url, this.image ) != -1 )
   {
     return;
   }
   
   
   this.image.push( image_url );
}  

ProductObj.prototype.AddConfigurableChild = function( product )
{
   if( false == this.hasOwnProperty( "configurable_children" ) )
   {
      this.configurable_children                      = new Array();
   }
  
   this.configurable_children.push( product ); 
  
   if( false == productObj.hasOwnProperty( "configurable_children_ids" ) )
   {
      productObj.configurable_children_ids           = new Array();
   }
   product_id                                        = parseInt( product.id );
   if( -1 == jQuery.inArray( product_id, productObj.configurable_children_ids ) )
   {
      productObj.configurable_children_ids.push( product_id );
   }
    console.log( this );
}

ProductObj.prototype.GetImageTableData =  function()
{
  append_text               =  "";

  if(  productObj.hasOwnProperty( "image" ) )
  {
    $.each( this.image, function( index, image_url ){
      append_text            +=  "<tr><td class='center'><div class='input-prepend input-append'><img src='" + image_url  + "' width=100px height=50px /></div></td><td class='center'><div class='input-prepend input-append'><input id='image' class ='attribute_value' type='text' size='16' name='attributes[image]' value='" + image_url +"' /></div></td><td><a class=\"btn btn-danger\" href=\"javascript:void(0);\" rel=\"nofollow\" onclick=\"delImg(" + index + ")\"><i class=\"icon-trash icon-white\"></i>删除</a></td></tr>";
    });
  }
  return append_text;
}

ProductObj.prototype.GetConfigurableChildTableData =  function()
{
  append_text               =  "";
  if(  productObj.hasOwnProperty( "configurable_children" ) )
  {
    $.each( this.configurable_children, function( index, product ){
    //  append_text            +=  "<tr><td class='center'><div class='input-prepend input-append'><span>"+ product.name +"</span></div></td><td class='center'><div class='input-prepend input-append'><span>" + product.price + "</span></div></td></tr>";
      append_text            +=  "<tr><td class='center'>" + product.name + "</td><td class='center'>"+ product.sku +"</td><td class='center'>" + product.price + "</td><td class='center'>" + product.qty + "</td></tr>";
    });
  }
  console.log( append_text );
  return append_text;
}

var productObj              = new ProductObj( PRODUCT_ENTITY );

function RefreshImageTable()
{
    $("#product_images_tbody").empty();
    table_data                  = productObj.GetImageTableData();
    $("#product_images_tbody").append( table_data );
}

function RefreshConfigurableChildTable()
{
  $("#simple_products_tbody").empty();
  table_data                  = productObj.GetConfigurableChildTableData();
  $("#simple_products_tbody").append( table_data );
}

function UpdateProductAttribute()
{
   $(".controls .attribute_value").each(function(){
     var attribute              =  $(this).attr("id");
     var value                  =  $(this).val();

     if( attribute == 'image' )
     {
       productObj.AddImage( value );
       return;
     }

     productObj[attribute]    =  value;
  }); 
}

function delImg( index )
{
  if(  productObj.hasOwnProperty( "image" ) && productObj['image'].length > index )
  {
    productObj['image'].splice( index, 1 );
    RefreshImageTable();
  }
}

$(function () {
 
  $("#image-management").click(function(e){
        window.open('/image_management','_blank','width=1200,height=600,scrollbars=yes');
        return false;
  });

  $("#categories_tree")
	.jstree({ 
		// List of active plugins
		"plugins" : [ 
			"themes","json_data","ui","checkbox","cookies"
		],

		// I usually configure the plugin that handles the data first
		// This example uses JSON as it is most common
		"json_data" : { 
			// This tree is ajax enabled - as this is most common, and maybe a bit more complex
			// All the options are almost the same as jQuery's AJAX (read the docs)
			"ajax" : {
				// the URL to fetch the data
				"url" : "/categories/get_tree.json",
				// the `data` function is executed in the instance's scope
				// the parameter is the node being loaded 
				// (may be -1, 0, or undefined when loading the root nodes)
				"data" : function (n) {
                                        // the result is fed to the AJAX request `data` option
                                        return {
		                                          "parent_id" : n.attr ? n.attr("id") : 0,
                                              "product_id" : PRODUCT_ID
                                        };
                                    }
			}
		},
		// UI & core - the nodes to initially select and open will be overwritten by the cookie plugin

		// the UI plugin - it handles selecting/deselecting/hovering nodes
		"ui" : {
			// this makes the node with ID node_4 selected onload
			"initially_select" : []
		},
		// the core plugin - not many options here
		"core" : { 
			// just open those two nodes up
			// as this is an AJAX enabled tree, both will be downloaded from the server
			"initially_open" : [] 
		}
	});

  $("#btn-submit-product").bind("click", function(){
      var ids      = "[";
      var ids_arr  = new Array;
      var nodes    = $("#categories_tree").jstree("get_checked"); //使用get_checked方法 
      $.each(nodes, function(i, n) { 
        if( i == 0 )
        {
          ids     += $(n).attr("id");
        }
        else
        {
          ids     += "," + $(n).attr("id");
        }
        ids_arr.push( $(n).attr("id") );
      });
     ids += "]";
     $("#categories").val( ids ); 

     productObj.categories = ids_arr;
 
     $('input[type="checkbox"][name="selected_simple_products"]:checked').each(
         function(){
            product_id = parseInt( $(this).val() );
            if( false == productObj.hasOwnProperty( "configurable_children_ids" ) )
            {
               productObj.configurable_children_ids           = new Array();
            }      
            if( -1 == jQuery.inArray( product_id, productObj.configurable_children_ids ) )
            {
              productObj.configurable_children_ids.push( product_id );
            }
     });

     UpdateProductAttribute();
     body                  = JSON.stringify( productObj );
     $("#body").val( body ); 

     $("#new_product").submit();
  });
  
  $("#btn-submit-edit-product").bind("click", function(){
     var ids      = "[";
     var ids_arr  = new Array;
     var nodes    = $("#categories_tree").jstree("get_checked"); //使�~T�get_checked�~V��~U
     $.each(nodes, function(i, n) {
       if( i == 0 )
       {
         ids     += $(n).attr("id");
       }
       else
       {
         ids     += "," + $(n).attr("id");
       }
       ids_arr.push( $(n).attr("id") );
     });
     ids += "]";
     $("#categories").val( ids );

     productObj.categories = ids_arr;

     $('input[type="checkbox"][name="selected_simple_products"]:checked').each(
         function(){
            product_id = parseInt( $(this).val() );
            if( false == productObj.hasOwnProperty( "configurable_children_ids" ) )
            {
               productObj.configurable_children_ids           = new Array();
            }
            if( -1 == jQuery.inArray( product_id, productObj.configurable_children_ids ) )
            {
              productObj.configurable_children_ids.push( product_id );
            }
     });

     UpdateProductAttribute();
     body                  = JSON.stringify( productObj );
     $("#body").val( body );
     $("#edit_product").submit();
  });
 
  $(".controls .attribute_value").live("blur", function(){
    var attribute              =  $(this).attr("id"); 
    var value                  =  $(this).val();

    if( attribute == 'image' )
    {
      return;
    }
    
    if( attribute == 'price' && parseInt( productObj.minimum_price ) > parseInt( value ) )
    {
      alert("售价必须高于最低价格");
      $(this).val( productObj.price );
      return;
    }
   
    productObj[attribute]      =  value;
  });
  

  $("#add-simple-product").bind("click", function(){
     window.open("/products/fast_new?set=" + productObj.attribute_set_id, '_blank', 'width=1200,height=600,scrollbars=yes');
     return false;
  });
  
  $("#btn-fast-add-product").live("click", function(){
      var ids      = "[";
      var ids_arr  = new Array;
      var nodes    = $("#categories_tree").jstree("get_checked");
      $.each(nodes, function(i, n) {
        if( i == 0 )
        {
          ids     += $(n).attr("id");
        }
        else
        {
          ids     += "," + $(n).attr("id");
        }
        ids_arr.push( $(n).attr("id") );
      });
     ids += "]";

     productObj.categories = ids_arr;
     UpdateProductAttribute();
     
     $.ajax({
              type: "POST",
              url: "/products/ajax_create",
              dataType: "json",
              processData: false,
              data: JSON.stringify( productObj ),
              success: function( data, status )
                       {
                         if( data["status"] == 1 )
                         {
                           window.opener.window.productObj.AddConfigurableChild( data['data'] );
                           window.opener.window.RefreshConfigurableChildTable();
                           window.close();
                         }
                         else
                         {         
                            alert( data['error_msg'] );
                         }
                       }
     });
  });
 

  RefreshImageTable();
  UpdateProductAttribute();
});
