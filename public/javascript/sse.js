var newMessage = function(message){
  $("#channel").append("<p><strong>"+ message.user_id +":  </strong>"+ message.text +"<span class='pull-right'>"+ message.created_at +"</span></p>");
  $("#channel").animate({ scrollTop: $(document).height() }, "slow");
}

$(document).ready(function(){

  $(document).bind("new_message", function(event, response) {
    newMessage(response.message.message);
  });

  eventSource.addEventListener("message", function(e) {
    var response = jQuery.parseJSON(e.data);

    $(document).trigger(response.type, response);
  });
});