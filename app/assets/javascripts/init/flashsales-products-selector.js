$(function () {
   
  $("#add-selected-products").bind("click", function(){
     var append_text      = "";
     $('input[name="product_selected"]:checked').each(function(){
       id                 = parseInt( $(this).val() );
       price_tag          = "#price_" + $(this).val();
       price              = parseFloat( $(price_tag).val() );
       name_tag           = "#name_"  + $(this).val();
       name               = $(name_tag).val();
       qty_tag            = "#qty_"   + $(this).val();
       qty                = parseInt( $(qty_tag).val() );

       product            = new Object();
       product.product_id = id;
       product.name       = name;
       product.price      = price;
       product.rule_price = price;
       product.qty        = qty;
       product.total_qty  = qty
       window.opener.window.flasheventObj.PushProduct( product );
     });
     
     window.opener.window.RefreshTable();
     window.close();
  });

});
