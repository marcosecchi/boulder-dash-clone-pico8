pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- Tabella contenente i dati del giocatore
Player = {}

-- Tabella contenente i dati del gioco (stato, etc.)
Game = {}

-- Tabella contenente le informazioni sui massi in caduta
FallingBoulders = {}

-- Funzione di callback lanciata da PICO-8 quando parte il gioco
function _init()
  Game.status = "start"
  ResetGame()
end

-- Funzione di callback lanciata da PICO-8 ad ogni frame
-- ed utilizzate per effettuare calcoli
function _update()
  -- Controllo le interazioni del giocatore
  CheckKeyPress()
end

-- Funzione di callback lanciata da PICO-8 ad ogni frame
-- ed utilizzate per 'disegnare' sullo schermo
function _draw()
  cls()
  if(Game.status == "start") then
    DrawStartScreen()
  elseif(Game.status == "game over") then
    DrawEndScreen()
  else
    DrawMap()
    DrawPlayer()
  end
end

function InitPlayer()
  Player.posX = 1
  Player.posY = 1
end

function CheckKeyPress()
  if(Game.status == "start" and btnp(4)) then
    sfx(2)
    Game.status = "play"
    return
  elseif (Game.status == "game over" and btnp(4)) then
    ResetGame()
    sfx(2)
    Game.status = "start"
    return
  end

  local nextPosX = Player.posX
  local nextPosY = Player.posY

  local moveInputPressed

  -- Calcolo il possibile movimento verticale del giocatore
  if(btnp(2)) then           -- Movimento in alto
    nextPosY = nextPosY - 1
    moveInputPressed = true
  elseif(btnp(3)) then       -- Movimento in basso
    nextPosY = nextPosY + 1
    moveInputPressed = true
  end  

  -- Calcolo il possibile movimento orizzontale del giocatore
  if(btnp(0)) then           -- Movimento a sinistra
    nextPosX = nextPosX - 1
    moveInputPressed = true
  elseif(btnp(1)) then       -- Movimento a destra
    nextPosX = nextPosX + 1
    moveInputPressed = true
  end

  -- Trovo il tipo di tile dove andrà a posizionarsi il giocatore
  nextTile = Map[nextPosY + 1][nextPosX + 1]
  
  -- Se è possibile muoversi (terreno vuoto o scavabile) aggiorno la posizione
  -- del giocatore, emettendo i suoni corrispondenti
  if(nextTile != 1 and nextTile != 2 and nextTile != 3 and nextTile != 6) then
    Map[Player.posY + 1][Player.posX + 1] = 7
    Player.posX = nextPosX
    Player.posY = nextPosY
  else
    -- Fermo, ha colpito il muro
  end

  if(moveInputPressed) then
    sfx(0)
    UpdateBoulders()
  end
end

function UpdateBoulders()
  for i, k in pairs(FallingBoulders) do
    Map[k.row][k.column] = 7
    Map[k.row + 1][k.column] = 6
    if(Player.posX + 1 == k.column and Player.posY + 1 == k.row + 1) then
      sfx(1)
      Game.status = "game over"
    end
  end

  FallingBoulders = {}

  for i, row in pairs(Map) do
    for j, column in pairs(row) do
    if(Map[i][j] == 6 and Map[i + 1][j] == 7) then
        local b = {}
        b.column = j
        b.row = i
        add(FallingBoulders, b)
      end
    end
  end
end

function ResetGame()
  Map = {}
  FallingBoulders = {}
  for i, row in pairs(mapTemplate) do
    local r = {}
    add(Map, r)
    for j, key in pairs(row) do
      add(r, key)      
    end
  end
  InitPlayer()
end

function DrawPlayer()
  spr(5, Player.posX * 8, Player.posY * 8)
end

function DrawMap()
  -- Ridisegna la mappa escludendo la tile dove si trova il giocatore
  for i, row in pairs(Map) do
    for j, key in pairs(row) do
      if(j - 1 != Player.posX or i - 1 != Player.posY) then
        spr(key, (j - 1) * 8, (i - 1) * 8)
      end
    end
  end
end

function DrawStartScreen()
  print("boulder dash (CLONE)", 26, 50, 6)
  print("press 'z' to start", 30, 60, 6)
end

function DrawEndScreen()
  print("crushed by a boulder!", 24, 50, 6)
  print("press 'z' to replay", 27, 60, 6)
end

Map = {}

mapTemplate = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 4, 4, 4, 4, 1},
    {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 2, 3, 2, 3, 2, 3, 2, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 4, 4, 4, 4, 6, 6, 2, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 4, 4, 4, 4, 4, 4, 2, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 2, 3, 2, 6, 4, 4, 4, 4, 4, 4, 4, 4, 1},
    {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
}
__gfx__
00000000dddddddd1777717777177777141144110040040000777700000000000000000000000000000000000000000000000000000000000000000000000000
00000000d11dd11d1477714777144777444f41440414414007474970000000000000000000000000000000000000000000000000000000000000000000000000
00700700d61dd61d14444144441444441f1114140044440094949747000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd1111111111111111f44f44410007700044444497000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd771777717777177711f44ff40045540044144944000000000000000000000000000000000000000000000000000000000000000000000000
00700700d11dd11d77144771477714774444144f0407704014414444000000000000000000000000000000000000000000000000000000000000000000000000
00000000d61dd61d44144441444414441ff4f4410095590001449440000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd11111111111111114f44444f0770077000111400000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000705006050060700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000336502b65029650216501c65017650106500b65006650036500165000600006002f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002d150311502b1001b1001b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
