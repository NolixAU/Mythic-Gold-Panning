AddEventHandler('GoldPanning:Shared:DependencyUpdate', RetrieveComponents)
function RetrieveComponents()
    Logger = exports['mythic-base']:FetchComponent('Logger')
    Callbacks = exports['mythic-base']:FetchComponent('Callbacks')
    Inventory = exports['mythic-base']:FetchComponent('Inventory')
    Fetch = exports['mythic-base']:FetchComponent('Fetch')
    Execute = exports['mythic-base']:FetchComponent('Execute')
end

AddEventHandler('Core:Shared:Ready', function()
    exports['mythic-base']:RequestDependencies('GoldPanning', {
        'Logger',
        'Callbacks',
        'Inventory',
        'Fetch',
        'Execute',
    }, function(error)
        if #error > 0 then
            return
        end

        RetrieveComponents()
        RegisterItemUse()
    end)
end)

function RegisterItemUse()
    if not GoldPanningConfig then
        Logger:Warn('GoldPanning', 'Gold panning config missing, skipping item registration')
        return
    end

    Inventory.Items:RegisterUse('goldpan', 'GoldPanning', function(source, item)
        Callbacks:ClientCallback(source, 'GoldPanning:AttemptPan', {}, function(success)
            if success then
                local char = Fetch:Source(source):GetData('Character')
                if char then
                    local selectedReward

                    for _, reward in ipairs(GoldPanningConfig.Rewards or {}) do
                        local chance = reward.chance or 1.0

                        if chance > 1 then
                            chance = chance / 100.0
                        end

                        if math.random() <= chance then
                            selectedReward = reward
                            break
                        end
                    end

                    if selectedReward then
                        Inventory:AddItem(char:GetData('SID'), selectedReward.name, selectedReward.count or 1, selectedReward.metadata or {}, 1)
                        Execute:Client(source, 'Notification', 'Success', 'You panned up something.')
                    else
                        Execute:Client(source, 'Notification', 'Error', 'You did not find anything this time.')
                    end
                end
            end
        end)
    end)
end