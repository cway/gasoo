$(function () {
	$("#products_list_table").dataTable({
	        "bProcessing": true,
	        "bServerSide": true,
	        "sAjaxSource": "/products/list",
	        "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span12'i><'span12 center'p>>",
	        "sPaginationType": "bootstrap",
	        "oLanguage": {
	          "sLengthMenu": "_MENU_ 条记录每页"
	        }
	  });
});