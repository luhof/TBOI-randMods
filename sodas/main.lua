local Sodas = RegisterMod("sodas", 1)
local game = Game()

local MIN_TEAR_DELAY = 5

local sodaId = {
  COKE        = Isaac.GetItemIdByName("Coke Zero"),
  ENERGY      = Isaac.GetItemIdByName("Energy Drink"),
  LEMONADE    = Isaac.GetItemIdByName("Lemonade"),
  ORANGESODA  = Isaac.GetItemIdByName("Orange Soda"),
  ROTTENSODA  = Isaac.GetItemIdByName("Rotten Soda"),
  SALTY       = Isaac.GetItemIdByName("Salty Water")
}

local hasSoda = {
  COKE = false,
  ENERGY = false,
  LEMONADE = false,
  ORANGESODA = false,
  ROTTENSODA = false,
  SALTY = false
}

local sodaBonus = {
  COKE = 1,
  ENERGY_TH = 1,
  ENERGY_FS = 1,
  ENERGY_SPEED = 0.5,
  LEMONADE = 1,
  ORANGESODA = 3,
  SALTY = 1
}

-- pill I'm always angry
local ImAlwaysAngry = {
    ID = Isaac.GetPillEffectByName("I'm Always Angry"),
    BONUS_DMG = 7,
    BONUS_TH = 30,
    SCALE = 1,
    IsAngry = false
}

ImAlwaysAngry.Color = Isaac.AddPillEffectToPool(ImAlwaysAngry.ID)

local function updateDrips(player)
    hasSoda.COKE = player:HasCollectible(sodaId.COKE)
    hasSoda.ENERGY = player:HasCollectible(sodaId.ENERGY)
    hasSoda.LEMONADE = player:HasCollectible(sodaId.LEMONADE)
    hasSoda.ORANGESODA = player:HasCollectible(sodaId.ORANGESODA)
    hasSoda.ROTTENSODA = player:HasCollectible(sodaId.ROTTENSODA)
    hasSoda.SALTY = player:HasCollectible(sodaId.SALTY)
end

-- on run start or continue
function Sodas:onPlayerInit(player)
    updateDrips(player)
end

-- on passive effect update
function Sodas:onUpdate(player)

  if game:GetFrameCount() == 1 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, sodaId.COKE,        Vector(320, 300), Vector(0, 0), nil)
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, sodaId.ENERGY,      Vector(270, 300), Vector(0, 0), nil)
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, sodaId.LEMONADE,    Vector(220, 300), Vector(0, 0), nil)
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, sodaId.ORANGESODA,  Vector(370, 300), Vector(0, 0), nil)
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, sodaId.SALTY,       Vector(420, 300), Vector(0, 0), nil)
      if player:GetName() == "Isaac" then
          player:AddCollectible(sodaId.ROTTENSODA, 0, true)
      end
  end

  updateDrips(player)

  --update angry pill effect
  if ImAlwaysAngry.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= ImAlwaysAngry.Room then
    player:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)
    player.SpriteScale = ImAlwaysAngry.FormerScale
    ImAlwaysAngry.IsAngry = false
    ImAlwaysAngry.Room = nil
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:AddCacheFlags(CacheFlag.CACHE_RANGE)
    player:EvaluateItems()
  end

end

function Sodas:onCache(player, cacheFlag)

    -- damage cache
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        if player:HasCollectible(sodaId.COKE) then
            if player.MaxFireDelay >= MIN_TEAR_DELAY + sodaBonus.COKE then
                player.MaxFireDelay = player.MaxFireDelay - sodaBonus.COKE
            elseif player.MaxFireDelay >= MIN_TEAR_DELAY then
                player.MaxFireDelay = MIN_TEAR_DELAY
            end
        end
        if player:HasCollectible(sodaId.SALTY) then
            player.Damage = player.Damage + sodaBonus.SALTY
        end

        if ImAlwaysAngry.IsAngry then
            player.Damage = player.Damage + ImAlwaysAngry.BONUS_DMG
        end
    end

    -- shotspeed cache
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        if player:HasCollectible(sodaId.LEMONADE)  then
            player.ShotSpeed = player.ShotSpeed + sodaBonus.LEMONADE
        end
    end

    -- range cache
    if cacheFlag == CacheFlag.CACHE_RANGE then
        if player:HasCollectible(sodaId.ENERGY) then
            player.TearHeight = player.TearHeight + sodaBonus.ENERGY_TH
            player.TearFallingSpeed = player.TearFallingSpeed + sodaBonus.ENERGY_FS
        end
        if ImAlwaysAngry.IsAngry then
            player.TearHeight = player.TearHeight - ImAlwaysAngry.BONUS_TH
        end
    end

    -- speed cache
    if cacheFlag == CacheFlag.CACHE_SPEED then
        if player:HasCollectible(sodaId.ENERGY) then
            player.MoveSpeed = player.MoveSpeed + sodaBonus.ENERGY_SPEED
        end
    end

    -- luck cache
    if cacheFlag == CacheFlag.CACHE_LUCK then
        if player:HasCollectible(sodaId.ORANGESODA) then
            player.Luck = player.Luck + sodaBonus.ORANGESODA
        end
    end

    -- flying cache
    if cacheFlag == CacheFlag.CACHE_FLYING then
        if player:HasCollectible(sodaId.ROTTENSODA) then
            player.CanFly = true
        end
    end

end


  Sodas:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Sodas.onPlayerInit)
  Sodas:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Sodas.onUpdate)
  Sodas:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Sodas.onCache)

-- I'm always angry proc code
function ImAlwaysAngry:Proc(_pillEffect)
    local player = game:GetPlayer(0)
    player:SetColor(Color(0.0, 0.7, 0.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)
    ImAlwaysAngry.FormerScale = player.SpriteScale
    player.SpriteScale = ImAlwaysAngry.FormerScale + Vector(ImAlwaysAngry.SCALE, ImAlwaysAngry.SCALE)
    ImAlwaysAngry.Room = game:GetLevel():GetCurrentRoomIndex()
    ImAlwaysAngry.IsAngry = true
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:AddCacheFlags(CacheFlag.CACHE_RANGE)

end

  Sodas:AddCallback(ModCallbacks.MC_USE_PILL, ImAlwaysAngry.Proc, ImAlwaysAngry.ID) -- id used to filter callback
