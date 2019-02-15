//= require libs/echart.min
//= require libs/moment.min

$(document).on('turbolinks:load', function() {
	$(".account").click(function(){
	  $(".account-panel").toggleClass("show");
	});

	$(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })

  $('input[name="authenticity_token"]').val(document.querySelector("meta[name=csrf-token]").content);

  $(".custom-control-input").on('change', function(e) {
	  var that;
	  that = "#" + e.target.getAttribute("id");
	  if ($(that).prop("checked") === true) {
	    $(that).val("true");
	  }
	  if ($(that).prop("checked") === false) {
	    return $(that).val("false");
	  }
	});
})