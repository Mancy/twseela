var line, mapDiv, map;
var markers = [];
var markersStartEndAddress = [];
//var markers_address = [];

var user_markers = [];
//var user_markers_address = [];

var geocoder;
var gasoline_km_per_letter = 12 ;
var start_point = null;
var end_point = null;
var infowindow = new google.maps.InfoWindow({
  content: ""
});

var markers_handelrs = true; 
var user_markers_handelrs = false;
var single_user_markers = true;

function initialize() {
  geocoder = new google.maps.Geocoder();
  
  if(markers.length > 0){
    lat = markers[0].position.lat();
    lng = markers[0].position.lng();
    zoom = 15;
  }else{
    lat = "27.442293572134986";
    lng = "30.654107449163227";
    zoom = 6;
  }
  
  
  mapDiv = document.getElementById('map-canvas');
  map = new google.maps.Map(mapDiv, {
    center: new google.maps.LatLng(lat, lng),
    zoom: zoom,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });

  line = new google.maps.Polyline({
    strokeColor: '#ff0000',
    strokeOpacity: 0.5,
    strokeWeight: 4
  });

  line.setMap(map);
  
  google.maps.event.addListener(map, 'click', newPoint);
  google.maps.event.addListener(map, 'click', newUserPoint);
  
}

function newPoint(e){
  if(markers_handelrs == true){
    addNewPoint(e.latLng);
  }
}

function addNewPointLngLat(lat, lng){
  myLatlng = new google.maps.LatLng(lat, lng);
  addNewPoint(myLatlng);
}

function newUserPoint(e){
  if(user_markers_handelrs == true){
    addNewUserPoint(e.latLng);
  }
}

function addNewUserPointLngLat(lat, lng){
  myLatlng = new google.maps.LatLng(lat, lng);
  addNewUserPoint(myLatlng);
}

function addNewUserPoint(latLng){
  if(single_user_markers == true && user_markers.length > 0){
    user_markers[0].setPosition(latLng);
    return true;
  }
  
  ico = "/images/icons/marker_user.png" ;
  marker = new google.maps.Marker({
    map: map,
    position: latLng,
    draggable: markers_handelrs,
    icon: ico
  });
  
  if(user_markers_handelrs == true){
    google.maps.event.addListener(marker, 'rightclick', function(event) {
      marker_index = getUserMarkerIndex(event.latLng);
      if(marker_index >= 0){
        //user_markers_address.splice(marker_index, 1)[0]
        marker = user_markers.splice(marker_index, 1)[0]
        marker.setMap(null);
        marker = null;
      }
    });
  }
  
  google.maps.event.addListener(marker, 'click', function(event) {
    codeLatLng(event.latLng);
  });
  
  user_markers.push(marker);
}

function addNewPoint(latLng){
  path = line.getPath();
  path.push(latLng);
  if(markers.length > 0 ){
    ico = "/images/icons/marker_red.png" ;
  }else{
    ico = "/images/icons/marker_green.png" ;
  }
  
  marker = new google.maps.Marker({
    map: map,
    position: latLng,
    draggable: markers_handelrs,
    icon: ico
  });
  
  if(markers_handelrs == true){
    google.maps.event.addListener(marker, 'dragend', function(event) {
      updateLine();
      updateDistance();
      //updateAllAddressFromLatLng();
    });
    
    google.maps.event.addListener(marker, 'rightclick', function(event) {
      marker_index = getMarkerIndex(event.latLng);
      if(marker_index >= 0){
        //markers_address.splice(marker_index, 1)[0]
        marker = markers.splice(marker_index, 1)[0]
        marker.setMap(null);
        marker = null;
        updateLine(); 
        updateDistance();
        //updateAllAddressFromLatLng();
      }
      if(markers.length > 1 ){
        markers[markers.length - 1].setIcon("/images/icons/marker_red.png")
        markers[0].setIcon("/images/icons/marker_green.png")
      }else if(markers.length == 1 )
      {
        markers[0].setIcon("/images/icons/marker_green.png")
      }
    });
  }
  
  google.maps.event.addListener(marker, 'click', function(event) {
    codeLatLng(event.latLng);
  });
  
  if(markers.length > 1 ){
    markers[markers.length - 1].setIcon("/images/icons/marker.png")
  }
  markers.push(marker);
  //updateCodeLatLng(marker.position);
  //codeLatLng(e.latLng);
  updateDistance();
  //updateAllAddressFromLatLng();
}

function updateLine(){
  line.setPath([]);
  path = line.getPath();
  
  for(var i=0; i < markers.length; i++){
    path.push(markers[i].position);
  }
}

function getMarkerIndex(pos){
  for(var i=0; i < markers.length; i++){
    if (markers[i].position == pos){
      return i;
    }
  }
  return -1;
}


function getUserMarkerIndex(pos){
  for(var i=0; i < user_markers.length; i++){
    if (user_markers[i].position == pos){
      return i;
    }
  }
  return -1;
}


function updateDistance()
{
  if(markers.length > 1){
    calcDistance();
  }else{
    removeDistance();
  }
  //updateHiddenFields();
}

function calcDistance()
{
  mtrs = google.maps.geometry.spherical.computeLength(line.getPath().b)
  kmtrs = Math.round(mtrs / 1000);
  
  if($(".car_profile:checked").size() > 0 ){
    cost_rate = Number($(".car_profile:checked").attr("gas_cost"));
    total_cost = (kmtrs / gasoline_km_per_letter) * cost_rate;
    $("#transport_cost_value").html(total_cost.toFixed(2) + " جنيه ");
    $("#transport_cost_value_input").val(total_cost.toFixed(2));
    $("#transport_mileage_value_input").val(kmtrs);
  }else{
    $("#transport_cost_value").html("لم يحدد");
    $("#transport_cost_value_input").val("");
    $("#transport_mileage_value_input").val("0");
  }
  
  $("#transport_km_value").html(kmtrs + " كيلومتر ");
}

function removeDistance()
{
  $("#transport_cost_value").html("لم يحدد");
  $("#transport_km_value").html("لم يحدد");
  $("#transport_cost_value_input").val("");
  $("#transport_mileage_value_input").val("0");
}

function codeAddress(elem) {
  var address = document.getElementById(elem).value;
  if(elem == "transport_start_point" && start_point == address){
    return false;
  }else if (elem == "transport_end_point" && end_point == address){
    return false;
  }else if(elem == "transport_end_point" && start_point == null){
    alert("برجاء اختيار بداية التوصيلة اولا");
    return false;
  }
  
  if(address.length > 0 ){
    if(elem == "transport_start_point"){
      start_point = address;
    }else if (elem == "transport_end_point"){
      end_point = address;
    }
    geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        
        if(elem == "transport_start_point"){
          start_point = address;
          if(markers[0]){
            markers[0].setPosition(results[0].geometry.location);
          }else{
            addNewPoint(results[0].geometry.location);
          }
        }else if (elem == "transport_end_point"){
          end_point = address;
          if(markers.length > 1 && markers[markers.length - 1]){
            markers[markers.length - 1].setPosition(results[0].geometry.location);
          }else{
            addNewPoint(results[0].geometry.location);
          }
        }
        
        updateLine();
        updateDistance();
      
        infowindow.setContent(address);
        infowindow.setPosition(results[0].geometry.location);
        infowindow.open(map);
      } else {
        alert("Geocode was not successful for the following reason: " + status);
      }
    });
  }else{
    if(elem == "transport_start_point"){
      start_point = null;
    }else if (elem == "transport_end_point"){
      end_point = null;
    }
  }
}

function codeLatLng(latlng) {
  geocoder.geocode({'latLng': latlng}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        infowindow.setContent(results[1].formatted_address);
        infowindow.setPosition(latlng);
        infowindow.open(map);
      }
    } else {
      alert("Geocoder failed due to : " + status);
    }
  });
}

function updateCodeLatLng(latlng) {
  geocoder.geocode({'latLng': latlng}, function(results, status){
    if (status == google.maps.GeocoderStatus.OK && results[1]){
      //markers_address.push(results[1].formatted_address);
    } else{
      //markers_address.push("");
    }
  });
}

function centerMarkersInMap(){
  latlngbounds = new google.maps.LatLngBounds();
  myLatlng_1 = new google.maps.LatLng(markers[0].position.lat(), markers[0].position.lng());
  myLatlng_2 = new google.maps.LatLng(markers[markers.length - 1].position.lat(), markers[markers.length - 1].position.lng());
  
  latlngbounds.extend(myLatlng_1);
  latlngbounds.extend(myLatlng_2);
  
  map.setCenter(latlngbounds.getCenter());
  map.fitBounds(latlngbounds); 
}

function updateAddressFromLatLng(){
  if(markers.length == 1){
    indx = 0;
    markersStartEndAddress[1] = "";
    marker_position = markers[0].position;
  }else if(markers.length > 1){
    indx = 1 ;
    marker_position = markers[markers.length - 1].position;
  }else{
    markersStartEndAddress[0] = "";
    markersStartEndAddress[1] = "";
    return true;
  }
  getAddressFromLatLng(marker_position, indx)
}

function updateAllAddressFromLatLng(){
  if(markers.length == 1){
    getAddressFromLatLng(markers[0].position, 0);
    markersStartEndAddress[1] = "";
  }else if(markers.length > 1){
    getAddressFromLatLng(markers[0].position, 0);
    getAddressFromLatLng(markers[markers.length - 1].position, 1);
  }else{
    markersStartEndAddress[0] = "";
    markersStartEndAddress[1] = "";
  }
}

function getAddressFromLatLng(gLatLng, indx){
  markersStartEndAddress[indx] = "";
  
  geocoder = new google.maps.Geocoder();
  geocoder.geocode({'latLng': gLatLng}, function(results, status){
    if (status == google.maps.GeocoderStatus.OK && results[1]){
      markersStartEndAddress[indx] = results[1].formatted_address;
    }
  });
}

$(document).ready(function (){
  initialize();
});