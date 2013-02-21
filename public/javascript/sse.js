var SSE = {
  eventSource: null,
  
  new_message_template: function(response){
    return "<div class='message'><div class='text'>"+ response.message.text +"</div><div class='meta'>Creado por "+response.user+" el "+response.message.created_at+"</div></div><hr>";
  },
  
  topic_changed_template: function(response){
    return "<p>"+response.new_topic+"</p>";
  },
  
  init: function(){
      SSE.eventSource = new EventSource("/stream");
      
      SSE.eventSource.addEventListener("topic_changed", function(e) {
        var response = jQuery.parseJSON(e.data);

        $("#current_topic").html(SSE.topic_changed_template(response));
      });
  
      SSE.eventSource.addEventListener("new_message", function(e) {
        var response = jQuery.parseJSON(e.data);
    
        $("#channel").append(SSE.new_message_template(response));
        $("#channel").animate({ scrollTop: $(document).height() }, "slow");
      });
  }
}

$(document).ready(function(){
  SSE.init();
});