Найти все возможные маршруты

Задача: https://gist.github.com/sanyco86/fcf5d047fe34fad981e8e0eb2021a031

1. app/services/flight_searcher.rb - класс для поиска и форматирования
   параметры на вход (пример):
   {carrier: "S7", origin_iata: "UUS", destination_iata: "DME", departure_from: '2022-09-01', departure_to: '2022-09-10'}

   ответ (пример):
   [
     {
      origin_iata: "UUS",
      destination_iata: "VVO",
      departure_time: 01 Sep 05:45,
      arrival_time: 01 Sep 07:40,
      segments: [{
         carrier: "S7",
         segment_number: "6224",
         origin_iata: "UUS",
         destination_iata: "VVO",
         std: 01 Sep 05:45,
         sta: 01 Sep 07:40,
     }]
   ]

2. spec/services/flight_sercher_spec.rb - тесты

