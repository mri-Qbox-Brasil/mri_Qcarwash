RegisterNetEvent('carwash:DoVehicleWashParticles', function(vehNet, use_props)
    local src = source
    TriggerClientEvent('carwash:DoVehicleWashParticles', -1, vehNet, src, use_props)
end)

lib.callback.register('carwash:CanPurchaseCarWash', function(source, cb)
    local src = source
    local Player = GetPlayer(src)
    print("getmoney ",GetPlayerAccountBalance(Player, Config.cash_account_name))
    if (GetPlayerAccountBalance(Player, Config.cash_account_name) >= Config.cost or GetPlayerAccountBalance(Player, Config.bank_account_name) >= Config.cost) then
        print("passou 1")
        if RemovePlayerMoney(Player, Config.cash_account_name, Config.cost, 'Washed Vehicle') then
            print("passou 2")

            return true
        elseif RemovePlayerMoney(Player, Config.bank_account_name, Config.cost, 'Washed Vehicle') then
            print("passou 3")

            return true
        end
    else
        print("return falses")
        return false
    end
end)