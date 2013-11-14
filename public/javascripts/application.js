var fancybox_options = {'speedIn'             : 300, 
                        'speedOut'            : 300,
                        'overlayColor'        : '#000',
                        'hideOnOverlayClick'  : true,
                        'overlayOpacity'      : 0.6,
                        'ajax'                : {data: {layout: false}}
                        };
                        
var fancybox_options_2 = {'speedIn'             : 300, 
                        'speedOut'            : 300,
                        'overlayColor'        : '#000',
                        'hideOnOverlayClick'  : false,
                        'overlayOpacity'      : 0.7,
                        'ajax'                : {data: {layout: false}},
                        'showCloseButton'     : false,
                        'enableEscapeButton'  : false
                        };
                                                
var carsNames = {"هيونداى": "Hyundai", "هوندا": "Honda", "هايما": "Haima", "نيسان": "Nissan", "ميني": "Mini", "مرسيدس": "Mercedes", "متسوبيشى": "Mistubishi", "سوزوكي": "Suzuki", "ستروين": "Citroen", "رينو": "Renault", "تويوتا": "Toyota", "بيجو": "Peugeot", "بى ام دبليو": "BMW", "بورش": "Porshce",  "بريليانس": "Brilliance", "بروتون": "Proton", "أوبل": "Opel", "أودى": "Audi", "ماهيندرا": "Mahindra", "اسبيرانزا": "Speranza", "جاجوار": "Jaguar", "روفر": "Rover", "لنكولن": "Lincoln", "كيا": "Kia", "مازدا": "Mazda", "لاند": "LandCruiser", "لادا": "Lada", "فولكس فاجن": "Volkswagen", "فولفو": "Volvo", "فيات": "Fiat", "فورد": "Ford", "كريسلر": "Chrysler", "شيفروليه": "Chevrolet", "سيات": "Seat", "سوبارو": "Subaru", "سكودا": "Skoda", "دودج": "Dodge", "دايهاتسو": "Daihatsu", "جيب": "Jeep", "جريت وول": "GreatWall", "لاند روفر": "LandRover", "هامر": "Hummer", "جي ام سي": "GMC"}

var dateTimePickerOptions = {
      ampm: true, 
      timeFormat: 'hh:mm TT',
      dateFormat: 'dd-mm-yy',
      firstDay: 7,
      isRTL: false,
      timeOnlyTitle: 'حدد الوقت',
      timeText: "الوقت", 
      hourText: 'الساعة',
      minuteText: 'الدقيقة',
      currentText: 'الوقت الأن',
      closeText: 'تم',
      monthNames: ['يناير','فبراير','مارس','ابريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'],
      dayNames: ['الأحد', 'الأثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
      dayNamesShort: ['حد', 'أثـ', 'ثلا', 'أربـ', 'خمـ', 'جمـ', 'سبت'], 
      dayNamesMin: ['حد', 'أثـ', 'ثلا', 'أربـ', 'خمـ', 'جمـ', 'سبت']
    };

var show_notification = false;
var show_request = false;
var show_messages = false;

$(document).ready(function () {
  $("span:[title]").tooltip({ position: "bottom left"});
  $("a:[title]").tooltip({ position: "bottom left"});
  $("label:[title]").tooltip({ position: "bottom left"});
  $("img:[title]").tooltip({ position: "bottom left"});
  $("div:[title]").tooltip({ position: "center left"});
  
  $(".fancybox.internal").each(function(){
    hrf = $(this).attr("href");
    $(this).attr("href", "#" + hrf.split("#")[1])
  });
  
  $("a.fancybox,a.iframe,#etrigger").fancybox(fancybox_options);
  
  $(".user_menu").live("click", function(event){
    $(".languages_drop_menu").hide("slow");
    $("#notification_drop_menu").hide("slow");
    $("#request_drop_menu").hide("slow");
    $("#messages_drop_menu").hide("slow");
    $(".user_drop_menu").slideToggle("fast");
    show_request = false;
    show_notification = false;
    show_messages = false;
    return false;
  });
  
  
  $(".notification_menu").live("click", function(event){
    $(".languages_drop_menu").hide("slow");
    $(".user_drop_menu").hide("slow");
    $("#request_drop_menu").hide("slow");
    $("#messages_drop_menu").hide("slow");
    $("#notification_drop_menu").slideToggle("fast");
    show_request = false;
    show_messages = false; 
    
    if(show_notification == true){
      show_notification = false;
    }else{
      show_notification = true;
    }
    
    if(show_notification == true){
      $("#notification_drop_menu").html("");
      $("#notify_menu_loader").tmpl({}).appendTo("#notification_drop_menu");
      $.ajax({
        datatType: 'script',
        url  : "/notifications.js", 
        data : {}
      })
    }
    
    return false;
  });
  
  $(".request_menu").live("click", function(event){
    $(".languages_drop_menu").hide("slow");
    $(".user_drop_menu").hide("slow");
    $("#notification_drop_menu").hide("slow");
    $("#messages_drop_menu").hide("slow");
    $("#request_drop_menu").slideToggle("fast");
    show_notification = false;
    show_messages = false; 
    
    if(show_request == true){
      show_request = false;
    }else{
      show_request = true;
    }
    
    if(show_request == true){
      $("#request_drop_menu").html("");
      $("#notify_menu_loader").tmpl({}).appendTo("#request_drop_menu");
      $.ajax({
        datatType: 'script',
        url  : "/users_requests.js", 
        data : {}
      })
    }
    
    return false;
  });
  
  $(".messages_menu").live("click", function(event){
    $(".languages_drop_menu").hide("slow");
    $(".user_drop_menu").hide("slow");
    $("#notification_drop_menu").hide("slow");
    $("#request_drop_menu").hide("slow");
    $("#messages_drop_menu").slideToggle("fast");
    show_notification = false;
    show_request = false;
    
    if(show_messages == true){
      show_messages = false;
    }else{
      show_messages = true;
    }
    
    if(show_messages == true){
      $("#messages_drop_menu").html("");
      $("#notify_menu_loader").tmpl({}).appendTo("#messages_drop_menu");
      $.ajax({
        datatType: 'script',
        url  : "/messages.js",
        data : {}
      })
    }
    
    return false;
  });
  
  $(".languages_menu").live("click", function(event){
    $(".user_drop_menu").hide("slow");
    $("#notification_drop_menu").hide("slow");
    $("#request_drop_menu").hide("slow");
    $("#messages_drop_menu").hide("slow");
    $(".languages_drop_menu").slideToggle("fast");
    show_request = false;
    show_notification = false;
    
    return false;
  });
  
});

function loadLoginHeader(){
  $.ajax({
    datatType: 'script',
    url  : "/login_header.js", 
    data : {}
  })
}

function showMsg(msg, msg_type){
  if(msg_type == "load"){
    msg_type_ext = "gif";
  }else{
    msg_type_ext = "png";
  }
  
  $("#msg_content p").html(msg);
  $("#msg_content img").attr("src", "/images/msg/" + msg_type + "." + msg_type_ext );
  
  if(msg_type == "load"){
    $("#show_msg_box").fancybox(fancybox_options_2).trigger('click');
    $("#fancybox-content a").attr("onclick", "return false;");
  }else{
    $("#show_msg_box").fancybox(fancybox_options).trigger('click');
  }
};


$(function() {
  if(!$.support.placeholder) { 
    var active = document.activeElement;
    $(':text').focus(function () {
      if ($(this).attr('placeholder') && $(this).attr('placeholder').length > 0 && $(this).val() == $(this).attr('placeholder')){
        $(this).val('').removeClass('hasPlaceholder');
      }
    }).blur(function () {
      if ($(this).attr('placeholder') && $(this).attr('placeholder').length > 0 && ($(this).val().length == 0 || $(this).val() == $(this).attr('placeholder'))){
        $(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
      }
    });
    $(':text').blur();
    $(active).focus();
    $('form').submit(function () {
      $(this).find('.hasPlaceholder').each(function() { 
        if($(this).val() == $(this).attr('placeholder')){
          $(this).val('');
        }
      });
    });
  }
});

Cookies = {
    //createCookie: function(name, value){
    //  var exdate=new Date();
    //  exdate.setDate(exdate.getDate() - 1 );
    //  document.cookie = name + "=" + value + "; expires=" + exdate.toUTCString();
    //},
    createCookie: function(name,value,days) {
      if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toUTCString();
      }
      else var expires = "";
      document.cookie = name+"="+value+expires+"; path=/";
    },
    readCookie: function(c_name){
        if (document.cookie.length>0){
          c_start=document.cookie.indexOf(c_name + "=");
          if (c_start!=-1){
            c_start=c_start + c_name.length+1;
            c_end=document.cookie.indexOf(";",c_start);
            if (c_end==-1) c_end=document.cookie.length;
            ms_val = decodeURIComponent(document.cookie.substring(c_start,c_end)).replace(/\+/g, " ");
            //Cookies.eraseCookie(c_name);
            return ms_val;
          }
        }
        return "";
    },
    eraseCookie: function(name){
        Cookies.createCookie(name, "");
    }
}