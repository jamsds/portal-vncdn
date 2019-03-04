//= require libs/echart.min
//= require libs/moment.min
//= require libs/cc-format

$(document).on('turbolinks:load', function() {
	$(".portal__main-navigation-account-avatar").click(function(){
	  $(".portal__main-navigation-account-panel").toggleClass("show");
	});

	$(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })

  // $('input[name="authenticity_token"]').val(document.querySelector("meta[name=csrf-token]").content);

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

  $(document).on("keypress", 'form', function (e) {
    var code = e.keyCode || e.which;
    if (code == 13) {
      $(".ssid_check, .btn-signon").click();
      return false;
    }
  });

	$(".free-trial-message-close").click(function(){
    var now = new Date();
    var time = now.getTime();
    time += 86400 * 1000;
    now.setTime(time);

    $(".free-trial-message").addClass("hidden");
    $(".dashboard__container").css("height","calc(100vh - 100px)");
    $(".portal__main-navigation").css("background-color","#f1f1f1");
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

  $("#amount").on('keyup', function() {
    if ($("#amount").val() != "" && parseInt($(this).val(), 10).toFixed(0) >= 500000) {
      $(".btn-deposit").click(function() {
        $(".deposit-confirm").toggleClass("hidden")
        $("#amount-value").text('₫' + parseFloat($("#amount").val(), 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString())
      });
      $(".btn-submit").click(function() {
        $("#form").submit();
      });
      $("#amountlHelp").removeClass("notice")
    } else {
      $("#amountlHelp").addClass("notice")
    }
  })

  $("#user_domain").on('keyup', function() {
    var hex = new RegExp(/^(?!:\/\/)([a-zA-Z0-9-_]+\.)*[a-zA-Z0-9][a-zA-Z0-9-_]+\.[a-zA-Z]{2,11}?/i)
    if (hex.test($(this).val()) == true) {
      $("#domainHelp").removeClass("notice")
    } else {
      $("#domainHelp").addClass("notice")
    }
  })

  $("#color-hex").on('keyup', function() {
    var hex = new RegExp(/^#([0-9a-f]{6})$/i)
    if (hex.test($(this).val()) == true) {
      $("#colorHelp").removeClass("notice")
    } else {
      $("#colorHelp").addClass("notice")
    }
  })

  $(".ssid_check").on('click', function() {
    axios.post('/api/v1.1/checkSSID/?email=' + $("#user_email").val()).then(function(response) {
      window.location.href = '/users/sign_in?_ssid=checked';
    })
  })

  $("#subnet").on('keyup', function() {
    ip = new RegExp(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/g)
    subnet = new RegExp(/([0-9]|[0-9]\d|1\d{2}|2[0-4]\d|25[0-5])(\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])){3}\/\d+/g)

    if (ip.test($(this).val()) == true || subnet.test($(this).val()) == true) {
      $("#subnetHelp").removeClass("notice")
    } else {
      $("#subnetHelp").addClass("notice")
    }
  })

  $(".readable").on('click', function() {
    $(this).toggleClass( "true" );
    if ($("#user_password").attr("type") == "password") {
      $("#user_password").attr("type", "text");
    } else {
      $("#user_password").attr("type", "password");
    }
  })

  $(".policy-edit").on('click', function() {
    $(".dashboard__container-policy-edit").removeClass("hidden")
    $("#policyId").val($(this).attr("data-id"));
    $("#name").val($(this).attr("data-name"));
    $("#url").val($(this).attr("data-url"));
    $("#location").val($(this).attr("data-location"));
    $("#subnet").val($(this).attr("data-subnet"));
    $("#type").val($(this).attr("data-type"));
  })

  $(".policy-edit-cache").on('click', function() {
    $(".dashboard__container-policy-edit").removeClass("hidden")
    $("#policyId").val($(this).attr("data-id"));
    $("#name").val($(this).attr("data-name"));
    $("#url").val($(this).attr("data-url"));
    $("#hostHeader").val($(this).attr("data-host"));
    $("#ttl").val($(this).attr("data-ttl"));

    if ($(this).attr("data-ignore-client") == "true") {
      $("#ignoreClientNoCache").click()
    }

    if ($(this).attr("data-ignore-origin") == "true") {
      $("#ignoreOriginNoCache").click()
    }

    if ($(this).attr("data-ignore-query") == "true") {
      $("#ignoreQueryString").click()
    }
  })
})