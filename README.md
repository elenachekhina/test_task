Найти все возможные маршруты

Задача: https://gist.github.com/sanyco86/fcf5d047fe34fad981e8e0eb2021a031

1. app/models/route.rb - класс маршрута, умеет себя форматировать и хранит в себе сегменты маршрута
2. app/services/route_searcher.rb - класс для поиска маршрутов, возвращает массив маршрутов
3. app/services/search_route_service.rb - класс для поиска и формирования ответа (в нем вызывается route_searcher)
   
   параметры на вход search_route_service (пример):
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

5. spec/models/route.rb - тесты
6. spec/services/route_searcher_spec.rb - тесты
7. spec/services/search_route_service_spec.rb - тесты


Чтобы запустить:

1. Создать .env
2. bin/rails db:create
3. bin/rails db:migrate
4. rake db:import
