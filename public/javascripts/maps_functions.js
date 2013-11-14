function getAddress(elem, lat, lng){  
  gLatLng = new google.maps.LatLng(lat, lng);
  
  geocoder = new google.maps.Geocoder();
  geocoder.geocode({'latLng': gLatLng}, function(results, status){
    if (status == google.maps.GeocoderStatus.OK && results[1]){
      elem.find(".latlng").html(results[1].formatted_address);
      elem.show();
    }
  });
}

$(document).ready(function (){
  $('.latlng_to_str').each(function(index) {
    elem = $(this);
    
    getAddress(elem, elem.find(".lat").html(), elem.find(".lng").html());
  });
});