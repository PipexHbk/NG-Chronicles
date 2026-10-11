################################################################################
#
#           *** COMPROBACIÓN DE QUE TIENES LA DEX COMPLETA ***
#                          Script por Skyflyer
#
################################################################################
#
# INSTRUCCIONES:
#
# Este script permite saber si tienes completa o no la dex tanto del modo
# clásico como del modo completo. Lo primero que hay que hacer es añadir en 
# POKEXEXTRADEXCLASICO los pokémon que no pertenecen a los primeros 251 Pokémon
# de la dex pero que también se han de tener en cuenta (si por ejemplo añadimos
# a Togekiss y a Yanmega, que son el 468 y 469 respectivamente, pondríamos:
#
# POKEXEXTRADEXCLASICO = [
# 468,
# 469
# ]
#
# También habría que hacer lo mismo con POKESSOBRANDEXCOMPLETA, en este caso 
# sería para indicar qué Pokémon no tenemos en cuenta en la pokédex nacional.
# Para añadir por ejemplo a Missigno, que es el 908, se pondría como los
# anteriores.
#
# Por último, habría que actualizar la variable TOTALDEPOKESENDEXNACIONAL con
# el número total de Pokémon que tienes en tu PBS Pokémon.txt.
#
#
# COMPROBAR INGAME SI TIENES LA DEX ENTERA:
#
# Rama condicional en tu evento y ponerlo en modo script, y ahí dentro escribir
# "detectarDexModoClasico()" si estás en modo clásico o 
# "detectarDexModoCompleto()" si estás en modo completo. Si la dex está
# completa, la rama condicional pasará por la primera opción, pero si te falta
# algún Pokémon, lo hará por el "else".
#
#
# El script también te da la opción de indicarte cuántos pokémon te quedan por
# ver. Se podría llamar a la función con la llamada a script y guardar su 
# valor en una variable, para poder operar con él o mostrarlo al jugador.
# Ver más abajo cada función para saber cómo llamarlas.
#
# Para guardar el valor de los Pokémon que llevas en modo clásico se podría
# poner, por ejemplo:
# 
#     $game_variables[1] = pokesTienesDexClasico()
#
# Esto almacenaría en la variable 1 la cantidad de Pokémon que tienes del modo
# clásico. Para mostrarlo en el texto de un evento se usaría así (con el comando
# show message del evento):
#
#     "Hola, tienes actualmente \[1] Pokémon de la Pokédex del modo clásico."
# 
################################################################################


# Añadir aquí los números de dex de Pokes adicionales a los 251 primeros para
# el modo clásico
POKEXEXTRADEXCLASICO = [
]

# Añadir aquí qué Pokémon no se tienen en cuenta en la dex nacional.
POKESSOBRANDEXCOMPLETA = [
 # Missigno
]

# Poner aquí el total de Pokémon que tiene el PBS.
TOTALDEPOKESENDEXNACIONAL = 1039

#------------------------------------------------------------------------------#

#########################################################
# Comprobar que tienes todos en la dex del modo clásico #
#########################################################
def detectarDexModoClasico()
  completada = true
  for i in 1..1039
    completada = false if !$Trainer.hasOwned?(i)
    return completada if !completada
  end
  for i in POKEXEXTRADEXCLASICO
    completada = false if !$Trainer.hasOwned?(i)
  end
  return completada
end

##################################################
# Saber cuántos Pokémon llevas de la dex clásica #
##################################################
def pokesTienesDexClasico()
  numPokes = 0
  for i in 1..1039
    numPokes+=1 if $Trainer.hasOwned?(i)
  end
  for i in POKEXEXTRADEXCLASICO
    numPokes +=1 if !$Trainer.hasOwned?(i)
  end
  return numPokes
end

#####################################################
# Saber cuántos Pokémon te faltan de la dex clásica #
#####################################################
def pokesFaltanDexClasico()
  numPokes = 1039
  for i in POKEXEXTRADEXCLASICO
    numPokes +=1 if !$Trainer.hasOwned?(i)
  end
  return numPokes - pokesTienesDexClasico()
end

#------------------------------------------------------------------------------#

#############################################################
# Función para comprobar que tienes la dex  nacional entera #
#############################################################
def detectarDexModoCompleto()
  completada = true
  for i in 1..TOTALDEPOKESENDEXNACIONAL
    if !$Trainer.hasOwned?(i) && !POKESSOBRANDEXCOMPLETA.include?(i)
      completada = false
      break
    end
  end
  return completada
end

###################################################
# Saber cuántos Pokémon llevas de la dex completa #
###################################################
def pokesTienesDexCompleto()
  numPokes = 0
  for i in 1..TOTALDEPOKESENDEXNACIONAL
    if !$Trainer.hasOwned?(i) && !POKESSOBRANDEXCOMPLETA.include?(i)
      numPokes +=1
    end
  end
  return numPokes
end

######################################################
# Saber cuántos Pokémon te faltan de la dex completa #
######################################################
def pokesFaltanDexCompleto()
  numPokes = TOTALDEPOKESENDEXNACIONAL - POKESSOBRANDEXCOMPLETA.size
  return numPokes - pokesTienesDexCompleto()
end

#------------------------------------------------------------------------------#

# Función de testeo para rellenar rápido la dex (te pone como obtenidos
# desde el 1 hasta el poke que le digas).
def auxiliarRellenarDex(numPokes)
  for i in 1..numPokes
    $Trainer.setSeen(i)
    $Trainer.setOwned(i) if !POKESSOBRANDEXCOMPLETA.include?(i)
  end
end