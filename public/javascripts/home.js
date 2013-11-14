var wrapper_width = $("#wrapper_div").width();
var slider_width = $("#home_container").width();
var width_diff = (wrapper_width - slider_width) / 2 ;
var slider_right = 0;
var step = 30;
var timer = null;
var millisec = 101;
var stop_timer = true;
var move_left = true;
  
$(document).ready(function(){
  $(".section_item").mouseover(function(){
    $(this).find(".label").show();
  }).mouseleave(function(){
    $(this).find(".label").hide();
  });
  
  $(window).resize(function() {
    wrapper_width = $("#wrapper_div").width();
    slider_width = $("#home_container").width();
    width_diff = (wrapper_width - slider_width) / 2 ;
    slider_right = 0;
    $("#slider_div").css("right", slider_right + "px");
    updateIcons();
  });
  
  $("#wrapper_div").mousemove(function(event) {
    if(event.pageY > 120 && event.pageX > width_diff && event.pageX < width_diff + 150 ){
      move_left = false;
      stop_timer = false;
      if(timer === null){
        moveSlider();
      }
    }else if(event.pageY > 120 && event.pageX > wrapper_width - width_diff - 150 && event.pageX < wrapper_width - width_diff ){
      move_left = true;
      stop_timer = false;
      if(timer === null){
        moveSlider();
      }
    }else{
      stop_timer = true;
    }
  });
});

function moveSlider(){
  move = slider_right;
  if(move_left == true){
    move += step ;
  }else{
    move -= step ;
  }
  
  if(move > 0 || move < slider_width - 1660 ){
    timer = null;
    return false;
  }
  
  slider_right = move;
  $("#slider_div").css("right", slider_right + "px");
  if(stop_timer == true || slider_right > 0 ){
    timer = null;
  }else{
    timer = setTimeout(moveSlider,millisec);
  }  
  
  updateIcons();
}

function updateIcons(){
  if(slider_right >= -50){
    $("#next_icon").hide();
  }else{
    $("#next_icon").show();
  }
  
  if((wrapper_width - slider_right) > 1600){
    $("#previous_icon").hide();
  }else{
    $("#previous_icon").show();
  }
}
