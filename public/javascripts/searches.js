$(document).ready(function () {
  $( ".radio" ).buttonset();
  $( "#format" ).buttonset();
  
  
  $("#car_btn_click").click(function(){
    $("#v_content_container").toggle("slow");
    return false;
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
    //alert("will submit");
    updateHiddenFields();
    //alert("will submit 2 ");
    //return false;
  });
});

function updateHiddenFields(){
  $("#hidden_fields").html("");
  var addr = "";
  for (var i = 0; i < markers.length; i++)
  {
    idx = getMarkerIndex(markers[i].position);
    if(idx >= 0 ){
      addr = markers_address[idx];
    }
    $("#transport_path_templ").tmpl({"index": i, "start_place": addr, "start_lng": markers[i].position.lng(), "start_lat": markers[i].position.lat()}).appendTo("#hidden_fields");
  }
}