# -*- coding: utf-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

car_makes = {:Hyundai => "هيونداى", :Honda => "هوندا", :Haima => "هايما", :Nissan => "نيسان", :Mini => "ميني", :Mercedes => "مرسيدس", :Mistubishi => "متسوبيشى", :Suzuki => "سوزوكي", :Citroen => "ستروين", :Renault => "رينو", :Toyota => "تويوتا", :Peugeot => "بيجو", :BMW => "بى ام دبليو", :Porshce => "بورش", :Brilliance => "بريليانس", :Proton => "بروتون", :Opel => "أوبل", :Audi => "أودى", :Mahindra => "ماهيندرا", :Speranza => "اسبيرانزا", :Jaguar => "جاجوار", :Rover => "روفر", :Lincoln => "لنكولن", :Kia => "كيا", :Mazda => "مازدا", :LandCruiser => "لاند", :Lada => "لادا", :Volkswagen => "فولكس فاجن", :Volvo => "فولفو", :Fiat => "فيات", :Ford => "فورد", :Chrysler => "كريسلر", :Chevrolet => "شيفروليه", :Seat => "سيات", :Subaru => "سوبارو", :Skoda => "سكودا", :Dodge => "دودج", :Daihatsu => "دايهاتسو", :Jeep => "جيب", :GreatWall => "جريت وول", :LandRover => "لاند روفر", :Hummer => "هامر", :GMC => "جي ام سي"} 
gasoline_types = {:solar => ["سولار", "1.10"], :gasoline_80 => ["بنزين 80", "0.9"], :gasoline_90 => ["بنزين 90", "1.75"], :gasoline_92 => ["بنزين 92", "1.85"]}

#sourse : http://www.travelmath.com/cities-in/Egypt
#["name_en", "name_ar", "lat", "lng" ]
cities = [["Alexandria", "الإسكندرية", "31.1980556", "29.9191667" ], ["Aswan", "أسوان", "24.0875", "32.8988889" ], ["Asyut", "أسيوط", "27.1827778", "31.1827778" ], ["Behera", "البحيرة", "", "" ], ["Beni Suef", "بني سويف", "29.0638889", "31.0888889" ], ["Cairo", "القاهرة", "30.05", "31.25" ], ["Dakahlia", "الدقهلية", "", "" ], ["Damietta", "دمياط", "31.4194444", "31.815" ], ["El Faiyum", "الفيوم", "29.3077778", "30.84" ], ["Gharbia", "الغربية", "", "" ], ["Gizeh", "الجيزة", "30.0086111", "31.2122222" ], ["Ismailia", "الإسماعيلية", "30.5833333", "32.2666667" ], ["Kafr el-sheikh", "كفر الشيخ", "", "" ], ["Marsa Matruh", "مطروح", "31.35", "27.2333333" ], ["Minya", "المنيا", "", "" ], ["Monofeya", "المنوفية", "", "" ], ["El Wadi El Gedid", "الوادي الجديد", "", "" ], ["North of Siena", "شمال سيناء", "", "" ], ["Port Said", "بورسعيد", "31.2666667", "32.3" ], ["Qalyubya", "القليوبية", "30.1830556", "31.2052778" ], ["Qena", "قنا", "26.17", "32.7272222" ], ["Al Bahr Al Ahmar", "البحر الأحمر", "", "" ], ["El Sharkya", "الشرقية", "", "" ], ["Sohag", "سوهاج", "26.55", "31.7" ], ["South of Siena", "جنوب سيناء", "", "" ], ["Suez", "السويس", "29.9666667", "32.55" ], ["Luxor", "الأقصر", "25.6833333", "32.65" ], ["Helwan", "حلوان", "", "" ], ["6 of october", "6 أكتوبر", "29.8166667", "31.05" ]]

puts "> > > > > Add car makes . . . "
car_makes.each do |key, val|
  CarsMake.find_or_create_by_name_en(key, :name_ar => val)
end

puts "> > > > > Add gasoline types . . . "
gasoline_types.each do |key, val|
  GasolineType.find_or_create_by_name_en(key.to_s.titleize, :name_ar => val[0], :price => val[1])
end

puts "> > > > > Add cities . . . "
cities.each do |city|
  City.find_or_create_by_name_en(city[0], :name_ar => city[1], :lat => city[2], :lng => city[3])
end

puts "> > > > > Add graph db indexes . . . "
Graphdb.create_index()
Graphdb.create_index("relationship")