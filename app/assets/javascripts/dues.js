$(document).ready(function(){

  var handler = StripeCheckout.configure({
    key: $("#js-dues").data("key"),
    email: $("#js-dues").data("email"),

    token: function(token, args) {
        var tokenElem = $("<input type='hidden' name='token'>").val(token.id);
        $("#dues-form").append(tokenElem).submit();
        $("#js-dues").text("Updating...").attr("disabled", "disabled");
    }
  });

  $('#js-dues').on('click', function(e) {
    handler.open({
      name: "Double Union Dues",
      allowRememberMe: false
    });
    e.preventDefault();
  });



  $('.cancel-membership').click(
  function (e) {
    e.preventDefault();
    $('#cancel-btn').removeClass('hidden');
    $('#cancel-btn').addClass('cancel');
  }
);
});
