var new_search_ready = false;

$(document).ready(function () {
  $( ".radio" ).buttonset();
  $( "#format" ).buttonset();
  
  $("#transport_cost_type").change(function(){
    if($(this).val() == 1){
      $("#cost_container").show();
      $("#free_cost_container").hide();
    }else{
      $("#cost_container").hide();
      $("#transport_cost").val('');
      if($(this).val() == 2){
        //$("#free_cost_container").show();
      }else{
        $("#free_cost_container").hide();
      }
    }
  });
  
  $("#transport_return_back").click(function(){
    if($("#transport_return_back").attr("checked")){
      $("#return_back_start_time_container").show();
    }else{
      $("#return_back_start_time_container").hide();
    }
  });
  
  $("#car_btn_click").click(function(){
    $("#map_hint_container").hide("fast");
    $("#v_content_container").toggle("slow");
    return false;
  });
  
  $("#map_hint_click").click(function(){
    $("#v_content_container").hide("fast");
    $("#map_hint_container").toggle("slow");
    return false;
  });
  
  $(".car_profile").change(function(){
    updateDistance();
  });
  
  $("#transport_start_point").blur(function(){
    if($(this).val() != $(this).attr('placeholder')){
      codeAddress('transport_start_point');
    }
    //updateHiddenFields();
  });
  $("#transport_end_point").blur(function(){
    if($(this).val() != $(this).attr('placeholder')){
      codeAddress('transport_end_point');
    }
    //updateHiddenFields();
  });
  $('.date_and_time_picker').each(function(elm){
    $(this).datetimepicker(jQuery.extend(dateTimePickerOptions, {
      defaultDate: $(this).attr("date"),
      hour: $(this).attr("hour"),
      minute: $(this).attr("minute")
    }));
  })
  
  $("#new_transport").submit(function(){
    if(new_search_ready == false){
      updateAllAddressFromLatLng();
      showMsg("برجاء الأنتظار . . . ", "load");
      setTimeout("setNewSearchReady('#new_transport')", 2000);
      return false;
    }else{
      updateHiddenFields();
    }
  });
  
  
  $(".edit_transport").submit(function(){
    if(new_search_ready == false){
      updateAllAddressFromLatLng();
      showMsg("برجاء الأنتظار . . . ", "load");
      setTimeout("setNewSearchReady('.edit_transport')", 2000);
      return false;
    }else{
      updateHiddenFields();
    }
  });
  
  $("#new_search").submit(function(){
    if(new_search_ready == false){
      updateAllAddressFromLatLng();
      showMsg("برجاء الأنتظار . . . ", "load");
      setTimeout("setNewSearchReady('#new_search')", 1000);
      return false;
    }else{
      updateHiddenFields();
    }
  });
  
  $("#new_transports_request").submit(function(){
    updateHiddenUserFields();
  });
});

function lastHiddenIndex(){
  lindex = 0;
  if($("#hidden_fields div").size()){
    lid = $("#hidden_fields div:last").attr("id").split("_");
    lindex = lid[lid.length -1 ];
  }
  return lindex;
}

function updateHiddenFields(){
  $("#hidden_fields").html("");
  if(markers.length > 0){
    for (var i = 0; i < markers.length; i++)
    {
      $("#transport_path_templ").tmpl({"index": i, "start_lng": markers[i].position.lng(), "start_lat": markers[i].position.lat()}).appendTo("#hidden_fields");
    }
    $("#transport_place_templ").tmpl({"index": "999", "start_place": markersStartEndAddress[0], "end_place": markersStartEndAddress[1]}).appendTo("#hidden_fields");
  }
}

function updateHiddenUserFields(){
  $("#hidden_fields").html("");
  var addr = "";
  for (var i = 0; i < user_markers.length; i++)
  {
    $("#transport_request_meet_place_templ").tmpl({"meet_lng": user_markers[i].position.lng(), "meet_lat": user_markers[i].position.lat()}).appendTo("#hidden_fields");
  }
}

function setNewSearchReady(elem){
  new_search_ready = true;
  $(elem).submit();
}
