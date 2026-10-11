# ============================================================================
# Discord Rich Presence - VERSIÓN SIN JSON
# ============================================================================
# Script ultra-simple que NO usa JSON (compatible con RPG Maker XP vanilla)

module DiscordPresence
  CLIENT_ID = "1471370511950024887"  # Tu Client ID
  ENABLED = true
  
  def self.init
    self.update("Iniciando", "Pokemon Essentials")
  end
  
  def self.update(state = "Jugando", details = "")
    return unless ENABLED
    begin
      # Crear el JSON manualmente sin depender de la librería
      json_data = %{{"state":"#{state}","details":"#{details}","largeImageKey":"pokemonlogo","largeImageText":"Pokemon Essentials","timestamp":#{Time.now.to_i}}}
      
      File.open("discord_state.json", "w") do |f|
        f.write(json_data)
      end
    rescue
      # Fallar silenciosamente si hay error
    end
  end
  
  def self.shutdown
    self.update("Offline", "")
  end
end

# Inicializar cuando carga el juego
begin
  DiscordPresence.init
rescue
end

# Limpiar al salir
at_exit do
  begin
    DiscordPresence.shutdown
  rescue
  end
end
