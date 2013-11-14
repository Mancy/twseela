$(document).ready(function(){
  $(".stars_container.clickalbe a").mouseenter(function(){
    $(this).nextAll().removeClass("rated").addClass("rate");
    $(this).prevAll().removeClass("rate").addClass("rated");
  }).click(function(){
    $(this).colsest(".stars_container").hide("slow");
  });
  
  $(".stars_container.clickalbe").mouseleave(function(){
    $(this).find("a.with_vote").removeClass("rate").addClass("rated");
    $(this).find("a.with_no_vote").removeClass("rated").addClass("rate");
  });
  
  $(".add_stars").click(function(){
    $(this).closest(".all_controls_div").find(".stars_container").toggle("slow");
    return false;
  });
});