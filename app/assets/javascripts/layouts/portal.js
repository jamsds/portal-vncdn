$(document).on('turbolinks:load', function() {
	$(".account").click(function(){
	  $(".account-panel").toggleClass("show");
	});

	$(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })
})