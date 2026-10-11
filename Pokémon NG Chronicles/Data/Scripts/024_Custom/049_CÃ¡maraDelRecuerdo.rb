# Cámara del recuerdo - v2.2
# Script autocontenido: respeta la firma pbTrainerBattle enviada
# Evita cambios netos en dinero, permite derrota, y restaura/cur a tu equipo.
# Muestra "Terminando simulación..." tras finalizar cada combate (independiente del resultado).
# Pegar como nuevo script en RPG Maker XP (nombre del script: Cámara del recuerdo)

#Abre el script llamado exactamente: Cámara del recuerdo en el editor de Scripts.

#Localiza la sección de configuración al final donde están los registros (después de CamaraDelRecuerdo.clear_all).

#Añade una línea nueva usando la firma exacta:

#CamaraDelRecuerdo.register(switch_id, PBTrainers::CONST, "Nombre mostrado", "Mensaje al ser derrotado", is_double, form, can_lose, result_var, temp_player_level)

#Parámetros rápidos:

#switch_id: ID del Switch que activa el encuentro (Integer).

#PBTrainers::CONST: constante interna del entrenador (ej. PBTrainers::ALEFINAL).

#"Nombre mostrado": cómo aparece en el menú (String).

#"Mensaje al ser derrotado": texto que se pasa a pbTrainerBattle (String).

#is_double: true = combate doble, false = individual.

#form: forma del entrenador (normalmente 0).

#can_lose: true/false (el módulo fuerza permitir perder, pero mantiene el parámetro).

#result_var: variable donde se guarda el resultado (0 si no se usa).

#temp_player_level: Integer (>0) para forzar nivel temporal de todo tu equipo; usa nil para comportamiento automático (nivel máximo rival o 100).

#Guarda el script y activa en el juego el Switch correspondiente para que el encuentro aparezca en el menú.

#Ejemplo concreto (añadir debajo de la entrada de Ale):

#CamaraDelRecuerdo.register(300, PBTrainers::ERIKA, "Erika", "Buen combate.", false, 0, true, 0, 80)

module CamaraDelRecuerdo
  # Entry guarda los parámetros en la firma solicitada + switch + temp_player_level
  Entry = Struct.new(
    :switch_id,         # Integer: switch que habilita mostrar/usar este combate
    :trainer_const,     # constant (ej. PBTrainers::ALEFINAL)
    :display_name,      # String: nombre que aparece en el juego ("Ale")
    :defeat_message,    # String: mensaje al ser derrotado
    :is_double,         # true/false
    :form,              # Integer (normalmente 0)
    :can_lose,          # true/false (estos combates permitirán perder)
    :result_var,        # Integer variable para resultado (0 si no se usa)
    :temp_player_level  # Integer >0 para forzar nivel del jugador; nil = automático
  )

  @entries = []

  class << self
    # Registrar un combate.
    def register(switch_id, trainer_const, display_name, defeat_message, is_double, form, can_lose, result_var, temp_player_level=nil)
      @entries << Entry.new(switch_id, trainer_const, display_name, defeat_message, is_double, form, can_lose, result_var, temp_player_level)
    end

    def clear_all; @entries.clear; end
    def entries; @entries.clone; end

    # Menu público (llamar desde evento con: CamaraDelRecuerdo.show_menu)
    def show_menu
      available = @entries.select { |e| $game_switches[e.switch_id] }
      return if available.empty?
      cmds = available.map { |e| e.display_name } + ["Cancelar"]
      choice = Kernel.pbMessage("¿Con quién quieres combatir?", cmds, -1)
      return if choice < 0 || choice >= available.length
      entry = available[choice]
      run_entry_battle(entry)
    end

    private

    # --- helpers de estado del jugador ---
    def save_player_state
      saved = []
      $Trainer.party.each do |pk|
        if pk.nil?
          saved << nil
          next
        end
        info = {}
        info[:level] = (pk.respond_to?(:level) ? pk.level : nil) rescue nil
        info[:exp]   = (pk.respond_to?(:exp) ? pk.exp : nil) rescue nil
        info[:hp]    = (pk.respond_to?(:hp) ? pk.hp : nil) rescue nil
        info[:status] = (pk.respond_to?(:status) ? pk.status : nil) rescue nil
        saved << info
      end
      saved
    end

    def restore_player_state(saved)
      $Trainer.party.each_with_index do |pk, i|
        s = saved[i] || nil
        next if pk.nil? && s.nil?
        begin; pk.level = s[:level] if s && s[:level]; rescue; end
        begin; pk.exp   = s[:exp]   if s && s[:exp]; rescue; end
        begin; pk.hp    = s[:hp]    if s && s[:hp]; rescue; end
        begin; pk.status = s[:status] if s && s.has_key?(:status) && pk.respond_to?(:status=); rescue; end
        pk.calcStats if pk.respond_to?(:calcStats)
      end
    end

    def heal_full_player
      $Trainer.party.each do |pk|
        next if pk.nil?
        begin
          if pk.respond_to?(:heal)
            pk.heal
          else
            pk.calcStats if pk.respond_to?(:calcStats)
            pk.hp = pk.totalhp if pk.respond_to?(:totalhp)
            if pk.respond_to?(:status=)
              pk.status = 0 rescue nil
            else
              begin; pk.instance_variable_set(:@status, 0); rescue; end
            end
          end
        rescue; end
      end
    end

    def boost_player_to_level(target)
      $Trainer.party.each do |pk|
        next if pk.nil?
        begin; pk.level = target; rescue; end
        pk.calcStats if pk.respond_to?(:calcStats)
        begin; pk.hp = pk.totalhp if pk.respond_to?(:totalhp); rescue; end
      end
    end

    # --- intentos para preservar dinero sin tocar otros módulos ---
    def backup_money
      b = {}
      begin; b[:trainer_money] = $Trainer.money if $Trainer.respond_to?(:money); rescue; b[:trainer_money] = nil; end
      begin; b[:game_party_gold] = $game_party.gold if $game_party.respond_to?(:gold); rescue; b[:game_party_gold] = nil; end
      begin; b[:game_party_money] = $game_party.money if $game_party.respond_to?(:money); rescue; b[:game_party_money] = nil; end
      b
    end

    def restore_money(b)
      begin; $Trainer.money = b[:trainer_money] if b[:trainer_money] && $Trainer.respond_to?(:money=); rescue; end
      begin; $game_party.gain_gold(b[:game_party_gold] - $game_party.gold) if b[:game_party_gold] && $game_party.respond_to?(:gain_gold); rescue; end
      begin; $game_party.gold = b[:game_party_gold] if b[:game_party_gold] && $game_party.respond_to?(:gold=); rescue; end
      begin; $game_party.money = b[:game_party_money] if b[:game_party_money] && $game_party.respond_to?(:money=); rescue; end
    rescue; end
    # Nota: restauraciones usan múltiples rutas para cubrir distintas bases de Essentials.

    # --- carga simple de party rival ---
    def load_trainer_party(trainer_const, form)
      begin
        loaded = pbLoadTrainer(trainer_const, form) rescue nil
        return loaded[0].party if loaded && loaded.is_a?(Array) && loaded[0] && loaded[0].respond_to?(:party)
      rescue; end
      nil
    end

    def detect_max_enemy_level(trainer_const, form)
      party = load_trainer_party(trainer_const, form)
      if party && party.any?
        maxlvl = 0
        party.each do |pk|
          next if pk.nil?
          lvl = (pk.respond_to?(:level) ? pk.level : nil) rescue nil
          maxlvl = lvl if lvl && lvl > maxlvl
        end
        return maxlvl if maxlvl > 0
      end
      return 100
    end

    # Ejecuta el combate según entrada, preservando dinero y restaurando según resultado
    def run_entry_battle(entry)
      # determinar nivel objetivo temporal para jugador
      target = (entry.temp_player_level.is_a?(Integer) && entry.temp_player_level > 0) ? entry.temp_player_level : detect_max_enemy_level(entry.trainer_const, entry.form)
      target = 100 if !target || target < 1

      # BACKUP: estado jugador y dinero
      saved_player = save_player_state
      saved_money  = backup_money

      # aplicar boost temporal al jugador
      begin
        boost_player_to_level(target)
      rescue; end

      # Forzar que el combate pueda perderse según requisito
      entry_effective_can_lose = true

      result = nil
      begin
        # Llamada EXACTA a pbTrainerBattle con la firma solicitada
        result = pbTrainerBattle(entry.trainer_const, entry.display_name, entry.defeat_message, entry.is_double, entry.form, entry_effective_can_lose, entry.result_var)
      rescue Exception => e
        restore_player_state(saved_player)
        restore_money(saved_money)
        Kernel.pbMessage("Error al iniciar combate: #{e.message}")
        return
      ensure
        # Restaurar dinero y estado del jugador después del combate
        begin; restore_money(saved_money); rescue; end
        begin; restore_player_state(saved_player); rescue; end
      end

      # Determinar si el jugador perdió (estándar Essentials: false o nil al perder)
      lost = false
      begin
        lost = (result == false || result.nil?)
      rescue; end

      if lost
        begin; heal_full_player; rescue; end
      end

      # Mensaje final siempre mostrado tras terminar la simulación
      Kernel.pbMessage("Terminando simulación...")
    end
  end
end

# =========================
# CONFIGURACIÓN POR DEFECTO (solo Ale)
# =========================
CamaraDelRecuerdo.clear_all
# register(switch_id, trainer_const, display_name, defeat_message, is_double, form, can_lose, result_var, temp_player_level)
# Por defecto: switch 236 activa esta entrada; temp_player_level nil => detecta rival o usa 100 fallback
CamaraDelRecuerdo.register(007, PBTrainers::LEADER_MELLO, "Mello", "...", false, 0, true, 0, 35)

CamaraDelRecuerdo.register(8, PBTrainers::LEADER_SATAN, "Satanclaus", "...", false, 0, true, 0, 45)

CamaraDelRecuerdo.register(141, PBTrainers::MAXIMO, "Máximo", "...", false, 0, true, 0, 50)

CamaraDelRecuerdo.register(145, PBTrainers::CYNTHIA, "Cynthia", "...", false, 0, true, 0, 53)

CamaraDelRecuerdo.register(011, PBTrainers::LEADER_PIPEZ, "Pipez", "...", false, 0, true, 0, 60)

CamaraDelRecuerdo.register(172, PBTrainers::RIVAL_DARY, "Dary", "...", false, 0, true, 0, 60)

CamaraDelRecuerdo.register(182, PBTrainers::KIRIFINAL1, "Kirishima", "...", false, 0, true, 0, 62)

CamaraDelRecuerdo.register(182, PBTrainers::KIRIMELLO, "Mello&Kirishima", "...", true, 0, true, 0, 65)

CamaraDelRecuerdo.register(191, PBTrainers::TEAMNGLEADER, "Xenon Kusanagi", "...", false, 0, true, 0, 68)

CamaraDelRecuerdo.register(199, PBTrainers::GYMLEADERS_F, "Bea & Sabrina", "...", true, 0, true, 0, 60)

CamaraDelRecuerdo.register(203, PBTrainers::SHADOWSEMIFINAL, "Shadow", "...", false, 0, true, 0, 72)

CamaraDelRecuerdo.register(203, PBTrainers::FINALSHADOW, "NeoShadow", "...", true, 0, true, 0, 75)

CamaraDelRecuerdo.register(227, PBTrainers::WALLY, "Blasco", "...", false, 0, true, 0, 75)

CamaraDelRecuerdo.register(236, PBTrainers::ALEFINAL, "Ale", "...", true, 0, true, 0, 85)

CamaraDelRecuerdo.register(238, PBTrainers::RANAFINAL, "Luis", "...", true, 0, true, 0, 85)

CamaraDelRecuerdo.register(238, PBTrainers::ANGELFINAL, "Angel", "...", true, 0, true, 0, 85)

CamaraDelRecuerdo.register(240, PBTrainers::CRISFINAL, "Cris", "...", true, 0, true, 0, 85)

CamaraDelRecuerdo.register(247, PBTrainers::VOCALOID, "Hatsune Miku", "...", false, 0, true, 0, 58)

CamaraDelRecuerdo.register(244, PBTrainers::GOKU_VEGETA, "Goku & Vegeta", "...", true, 0, true, 0, 53)

CamaraDelRecuerdo.register(277, PBTrainers::REGENTEOR, "Origin", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(282, PBTrainers::REGENTEFL, "Flame", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(312, PBTrainers::REGENTECA, "Catrix", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(351, PBTrainers::REGENTEKR, "Karma", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(399, PBTrainers::PROFGARY, "Gary Oak", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(401, PBTrainers::DAMO2, "Damo", "...", true, 0, true, 0, 100)

CamaraDelRecuerdo.register(378, PBTrainers::KIRITO, "Kirito", "...", true, 0, true, 0, 100)

CamaraDelRecuerdo.register(408, PBTrainers::ARED, "Rojo", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(406, PBTrainers::GLADION, "Gladio", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(360, PBTrainers::RALFREDO, "Alfredo", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(362, PBTrainers::RCSDARK, "CsDark", "...", false, 0, true, 0, 100)

CamaraDelRecuerdo.register(361, PBTrainers::PIPEALE, "Pipez & Ale", "...", true, 0, true, 0, 100)