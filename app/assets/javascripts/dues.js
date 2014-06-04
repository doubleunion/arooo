$(document).ready(function(){

  var handler = StripeCheckout.configure({
    key: $("#dues").data("key"),

    token: function(token, args) {
      $.ajax({
        url: $("#dues").data("dues-path"),
        type: "POST",
        data: {
          "token": token.id,
          "email": token.email,
          "plan": $(".amount").val()
        },
        success: function() {
          $("#main .container").prepend('<div class="alert alert-success"><a class="close" data-dismiss="alert">×</a><div id="flash_notice">Your dues have been updated.</div></div>')
        }
      });
    }
  });

  $('#dues').on('click', function(e) {
    handler.open();
    e.preventDefault();
  });
});
