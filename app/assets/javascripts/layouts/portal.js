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

	$(".free-trial-message-close").click(function(){
    var now = new Date();
    var time = now.getTime();
    time += 86400 * 1000;
    now.setTime(time);

    $(".free-trial-message").addClass("hidden");
    $(".portal__main-navigation").css("background-color","#f8f8f8");
    document.cookie = 'freeTrial_messageDismiss=true; expires=' + now.toUTCString() + '; path=/';
  });

  $("#search").keyup(function() {
    var value = this.value;

    $("table").find("tr").each(function(index) {
      if (index === 0) return;
      var id = $(this).find("td").text();
      $(this).toggle(id.indexOf(value) !== -1);
    });
  });
})