var flasheventObj;

Date.prototype.format =function(format)
{
  var o = {
            "M+" : this.getMonth()+1, //month
            "d+" : this.getDate(), //day
            "h+" : this.getHours(), //hour
            "m+" : this.getMinutes(), //minute
            "s+" : this.getSeconds(), //second
            "q+" : Math.floor((this.getMonth()+3)/3), //quarter
            "S"  : this.getMilliseconds() //millisecond
          }

   if(/(y+)/.test(format)) format=format.replace(RegExp.$1,(this.getFullYear()+"").substr(4- RegExp.$1.length));
   for(var k in o)
   {
     if(new RegExp("("+ k +")").test(format))
     {
       format = format.replace(RegExp.$1, RegExp.$1.length==1? o[k] : ("00"+ o[k]).substr((""+ o[k]).length));
     }
   }
   return format;
}

function FlasheventObj( entity )
{
  this.from_date             = new Date();
  this.end_date              = new Date();
  this.products              = new Array();
  this.product_ids           = new Array();

  for(var entity_code in entity)
  {
      if( entity[entity_code] != null )
      {
        this[entity_code]           = entity[entity_code];
      }
  }  
  console.log( this );
}


FlasheventObj.prototype.FromDate    = function()
{
  return this.from_date.format('yyyy-MM-dd hh:mm:ss');
}

FlasheventObj.prototype.EndDate     = function()
{
  return this.end_date.format('yyyy-MM-dd hh:mm:ss');
}

FlasheventObj.prototype.PushProduct = function( product )
{
  if( jQuery.inArray( product.product_id, this.product_ids ) != -1 )
  {
    return;
  }

  $.ajax({
          type: "GET",
          url: "/products/get_children",
          dataType: "json",
          async: false,
          data: 'entity_id='+ product.product_id,
          success: function( data, status )
                   {
                     if( data["status"] == 1 )
                     { 
                       if( false == product.hasOwnProperty( "products" ) )
                       {
                          product['children']                 = new Object; 
                       }
 
                       $.each( data["data"], function(index, child_product){
                          product['children'][index]                 = new Object;
                          product['children'][index]["entity_id"]    = child_product['entity_id'];
                          product['children'][index]["name"]         = child_product['name'];
                          product['children'][index]["name"]         = child_product['name'];
                          product['children'][index]["sku"]          = child_product['sku'];
                          product['children'][index]["rule_price"]   = child_product['price'];
                          product['children'][index]["price"]        = child_product['price'];
                          product['children'][index]["total_qty"]    = child_product['qty'];
                          product['children'][index]["qty"]          = child_product['qty'];
                       });
                     }
                     else
                     {}
                   }
  });

  this.product_ids.push( product.product_id );
  this.products.push( product ); 
}

FlasheventObj.prototype.GetTableData = function()
{
   append_text             = "";
   if(  this.hasOwnProperty( "products" ) )
   {
     $.each( this.products, function(index, value){
        append_text  += "<tr><td>" + value.name + "</td><td class='center'>" + value.price + "</td><td class='center'><input size=16 type='text' class='input-xlarge rule_price_input'id='price_" + index  + "' value=" + value.rule_price + " /></td><td class='center'><input size=16 type='text' class='input-xlarge qty_input' id='qty_" + index  + "'  value=" + value.qty + " /></td><td><a class=\"btn btn-danger delete-flashsales-product\" id='del_product_" + index + "' href=\"javascript:void(0);\" rel=\"nofollow\" ><i class=\"icon-trash icon-white\"></i>删除</a></td></tr>";
        if( value.hasOwnProperty( "children" ) )
        {
          $.each( value.children, function( child_index, child_product )
          {
            append_text += "<tr><td>" + child_product.name + "</td><td class='center'>" + child_product.price + "</td><td class='center'><input size=16 type='text' class='input-xlarge rule_price_input'id='price_" + index + "_" + child_index + "' value=" + child_product.rule_price + " /></td><td class='center'><input size=16 type='text' class='input-xlarge qty_input' id='qty_" + index + "_" + child_index + "'  value=" + child_product.qty + " /></td><td><a class=\"btn btn-danger delete-flashsales-product\" id='del_product_" + index + "_" + child_index + "' href=\"javascript:void(0);\" rel=\"nofollow\" ><i class=\"icon-trash icon-white\"></i>删除</a></td></tr>";
          });
        }
     });
   }
   return append_text;
}


function RefreshTable()
{
  $("#falshsales_products_tbody").empty();
  table_data                  = flasheventObj.GetTableData(); 
  $("#falshsales_products_tbody").append( table_data );
}

function UpdateFlashsalesData()
{
  //TODO 
}

$(function () {

  flasheventObj               = new FlasheventObj( FLASHSALES_ENTITY );

  $(".datetimepicker").on('changeDate', function(e) {
      from_date                = e.localDate;
      end_date                 = new Date(e.localDate);
      end_date.setDate( end_date.getDate() + 1);
      flasheventObj.from_date  = from_date;
      flasheventObj.end_date   = end_date;
      $("#from-date").val( flasheventObj.FromDate() );
      $("#end-date").val( flasheventObj.EndDate() );
  });
 
  $("#add-flashsales-product-btn").bind('click', function(){

    var data =  window.open('/flashsales/products_selector','_blank','width=1200,height=600,scrollbars=yes');
    return false;
  });

  $(".qty_input").live("change", function(){
     id_mark       =  $(this).attr("id").split("_");

     if( id_mark.length == 2 )
     {
         id        =  parseInt(id_mark[1]);
         qty       =  parseInt($(this).val());
         if( qty > flasheventObj.products[id].total_qty )
         {
            alert("不能大于现有库存");
            $(this).val( flasheventObj.products[id].qty );
         }
         else
         {
            flasheventObj.products[id].qty = qty;
         }
      }
      else if( id_mark.length == 3 )
      {
         parent_id  =  parseFloat(id_mark[1]);
         child_id   =  parseFloat(id_mark[2]);
         qty        =  parseInt($(this).val());
         if( qty > flasheventObj.products[parent_id]["children"][child_id].total_qty )
         {
            alert("不能大于现有库存");
            $(this).val( flasheventObj.products[parent_id]["children"][child_id].qty );
         }
         else
         {
            flasheventObj.products[parent_id]["children"][child_id].qty = qty;
         }
      }
  });

  $(".rule_price_input").live("change", function(){
     id_mark      =  $(this).attr("id").split("_");

     if( id_mark.length == 2 )
     {
       id         =  parseFloat(id_mark[1]);
       rule_price =  parseFloat($(this).val());
       if( rule_price > flasheventObj.products[id].price )
       {
          alert("闪购价格不能大于市场价");
          $(this).val( flasheventObj.products[id].rule_price );
       }
       else
       {
          flasheventObj.products[id].rule_price = rule_price;
       }
     }
     else if( id_mark.length == 3 )
     {
       parent_id  =  parseFloat(id_mark[1]);
       child_id   =  parseFloat(id_mark[2]);
       rule_price =  parseFloat($(this).val());
       if( rule_price > flasheventObj.products[parent_id]['children'][child_id].price )
       {
          alert("闪购价格不能大于市场价");
          $(this).val( flasheventObj.products[parent_id]['children'][child_id].rule_price );
       }
       else
       {
          flasheventObj.products[parent_id]['children'][child_id].rule_price = rule_price;
       }
     }
     else
     {}
  });
 
  $("#add-flashevent-btn").bind("click", function(){ 
      body = JSON.stringify( flasheventObj );
      $("#body").val( body ); 
      $("#new_flashsales").submit();
  });  

  $("#edit-flashevent-btn").bind("click", function(){
     console.log( flasheventObj );
     body = JSON.stringify( flasheventObj );
     $("#body").val( body );
     $("#edit_flashsales").submit();
  });

  $(".delete-flashsales-product").live("click",function(){
     id_mark            = $(this).attr("id").split("_");
     if( id_mark.length == 3 )
     {
       id               =  parseFloat(id_mark[2]);
       flasheventObj.products.splice( id, 1 );
       flasheventObj.product_ids.splice( id, 1 );
       RefreshTable();
     }
     else if( id_mark.length == 4)
     {
        parent_id       =  parseFloat(id_mark[2]);
        child_id        =  parseFloat(id_mark[3]);
        delete flasheventObj.products[parent_id]["children"][child_id];     
        RefreshTable();
     }
     else{}
  });
  RefreshTable();
});
