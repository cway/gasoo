$(function () {
 $("#add-option").live( "click", function(){
   $(this).remove();
   $("#options-control").append('<div class="input-append"><input id="select-option" name="options[]" size="6" type="text" /><button class="btn" id="add-option" type="button">添加选项</button</div>');
 });
 
 $("#select-frontend-input").live("change", function(){
   if( $("#select-frontend-input").val() == "select" || $("#select-frontend-input").val() == "multiselect" )
   {
       $("#options-group").removeClass("hide");
   }
   else
   {
       $("#options-group").addClass("hide");
   }
 });
});
