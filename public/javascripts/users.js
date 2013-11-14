$(document).ready(function(){
  $( ".radio" ).buttonset();
  $( "#format" ).buttonset();
  
  
  $('#car_profile_color').ColorPicker({
    onSubmit: function(hsb, hex, rgb, el) {
      $(el).val(hex);
      $(el).css("background-color", "#"+hex)
      $(el).ColorPickerHide();
    },
    onBeforeShow: function () {
      $(this).ColorPickerSetColor(this.value);
    }
  }).bind('keyup', function(){
    $(this).ColorPickerSetColor(this.value);
  });
  
  $("#user_has_car_0").click(function(){
    $("#car_profile_container").hide();
    $("#add_to_car_list").hide();
    $("#cars_list_container").hide();
  });
  $("#user_has_car_1").click(function(){
    $("#car_profile_container").show();
    $("#add_to_car_list").show();
    $("#cars_list_container").show();
  });
  
  $(".delete_item").live("click", function(){
    car_porf_id = $(this).closest(".list_item").find("#user_car_profiles_attributes_id").val();
    
    if(car_porf_id.length > 0){
      elem_new_id = $("#cars_list_item_container #deleted_cars_list div").size() + 100 ;
      $("#cars_list_item_container #deleted_cars_list").append('<div><input type="hidden" value="' + car_porf_id + '" name="user[car_profiles_attributes][' + elem_new_id + '][id]" id="user_car_profiles_attributes_id"><input type="hidden" value="1" name="user[car_profiles_attributes][' + elem_new_id + '][_destroy]" id="user_car_profiles_attributes__destroy"></div>');
    }
    
    $(this).closest(".list_item").remove();
    if($("#cars_list_item_container .list_item").size() <= 1){
      $("#no_cars_item").show();
    }
    return false;
  });
  
  $("#add_car").click(function(){
    car_id = [-1];
    if($("#cars_list_item_container .real_list_item:last").size() > 0 ){
      car_id = $("#cars_list_item_container .real_list_item:last").attr("id").split("_");
    }
    car_profile_id = Number(car_id[car_id.length-1]) + 1;
    
    car_number_0 = $("#car_profile_number_0").val();
    car_number_1 = $("#car_profile_number_1").val();
    car_color = $("#car_profile_color").val();
    car_model = $("#car_profile_model_name").val();
    car_year = $("#car_profile_make_date_1i").val();
    
    car_make_id = $("#car_profile_cars_make_id").val();
    car_make_name = $("#car_profile_cars_make_id option:selected").html();
    car_make_image = carsNames[car_make_name];
    
    car_gas_id = $("#car_profile_gasoline_type_id").val();
    car_gas_name = $("#car_profile_gasoline_type_id option:selected").html();
    
    if(!car_number_0 || !car_color || !car_model || !car_year || !car_make_id || !car_gas_id){
      showMsg("بيانات السيارة التي قمت بكتابتها ناقصة وغير صحيحة . . برجاء استكمال جميع البيانات المطلوبة بصورة صحيحة", "warning");
      return false;
    }
    
    if(car_number_0.length < 2  || car_number_0.length > 6 || car_number_1.length > 6 ){
      showMsg("رقم اللوحة غير صحيح", "warning");
      return false;
    }
    
    $("#no_cars_item").hide();
    $("#car_profile_templ").tmpl({"number_0": car_number_0, "number_1": car_number_1, "make_name": car_make_name, "make_id": car_make_id, "model_name": car_model, "make_date": car_year, "gas_name": car_gas_name, "gas_id": car_gas_id, "color": car_color, "car_profile_id": car_profile_id, "car_make_image": car_make_image}).appendTo("#cars_list_item_container");
    
    $("#car_profile_number_0").val("");
    $("#car_profile_number_1").val("");
    $("#car_profile_color").val("");
    $("#car_profile_color").css("background-color", "#fff");
    $("#car_profile_model_name").val("");
    $("#car_profile_make_date_1i").val(0);
    $("#car_profile_cars_make_id").val(0);
    $("#car_profile_gasoline_type_id").val(0);
    
    return false;
  });
});