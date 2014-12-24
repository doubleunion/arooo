$(document).ready(function() {
  return $(".js-membership-note").on("ajax:success", function(e, data, status, xhr) {
    $(".save-success-" + data.user_id).fadeIn(500).delay(500).fadeOut(500);
  }).on("ajax:error", function(e, xhr, status, error) {
    $(".save-failure-" + data.user_id).fadeIn(500);
  });
});
