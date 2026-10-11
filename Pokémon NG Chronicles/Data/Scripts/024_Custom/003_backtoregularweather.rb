def pbBackToRegularWeather
  weather=pbGetMetadata($game_map.map_id,MetadataWeather)
  if weather
    $game_screen.weather(weather[0],8,20)  
  else
    $game_screen.weather(0,0,0)
  end  
end