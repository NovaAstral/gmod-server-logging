if SERVER then

function Nova_CheckLogFileDate()
    local date = os.date("%d %m %Y",os.time())
    local time = os.date("%I:%M:%S%p",os.time())
    
    if(not file.Exists("n_server_logs/chatlogs/log "..date..".txt","DATA")) then
        file.Write("n_server_logs/chatlogs/log "..date..".txt",time.." Log Start")
        print("Nova Server Logging: Chat Log file for today does not exist, creating.")
    end

    if(not file.Exists("n_server_logs/damagelogs/log "..date..".txt","DATA")) then
        file.Write("n_server_logs/damagelogs/log "..date..".txt",time.." Log Start")
        print("Nova Server Logging: Damage Log file for today does not exist, creating.")
    end

    if(not file.Exists("n_server_logs/entitylogs/log "..date..".txt","DATA")) then
        file.Write("n_server_logs/entitylogs/log "..date..".txt",time.." Log Start")
        print("Nova Server Logging: Entity Log file for today does not exist, creating.")
    end

    /*
    if(not file.Exists("n_server_logs/uselogs/log "..date..".txt","DATA")) then
        file.Write("n_server_logs/uselogs/log "..date..".txt",time.." Log Start")
        print("Nova Server Logging: Use Log file for today does not exist, creating.")
    end
    */
end

function Nova_CheckSecondaryLogDirs()
    if(not file.IsDir("n_server_logs/chatlogs","DATA")) then
        file.CreateDir("n_server_logs/chatlogs")
        print("Nova Server Logging: Secondary Log folder chatlogs does not exist, creating.")
    end

    if(not file.IsDir("n_server_logs/damagelogs","DATA")) then
        file.CreateDir("n_server_logs/damagelogs")
        print("Nova Server Logging: Secondary Log folder damagelogs does not exist, creating.")
    end

    if(not file.IsDir("n_server_logs/entitylogs","DATA")) then
        file.CreateDir("n_server_logs/entitylogs")
        print("Nova Server Logging: Secondary Log folder entitylogs does not exist, creating.")
    end

    /*
    if(not file.IsDir("n_server_logs/uselogs","DATA")) then
        file.CreateDir("n_server_logs/")
        print("Nova Server Logging: Secondary Log folder uselogs does not exist, creating.")
    end
    */
end

function Nova_CheckMainLogDir()
    print("Nova Server Logging: Checking log files.")
    
    if(not file.IsDir("n_server_logs","DATA")) then
        print("Nova Server Logging: Main Log folder does not exist, creating.")
        file.CreateDir("n_server_logs")

        Nova_CheckSecondaryLogDirs()

        Nova_CheckLogFileDate()
    else
        print("Nova Server Logging: Log folder exists, checking files.")

        Nova_CheckSecondaryLogDirs()

        Nova_CheckLogFileDate()
    end
end

hook.Add("InitPostEntity", "Nova Server Logging Init", function()
	print("Nova Server Logging Start")
    Nova_CheckMainLogDir()

    for I = 1,#ents.GetAll() do
        if I == #ents.GetAll() then
            map_start_ent_amount = #ents.GetAll()
        end
    end

    Nova_Logging_CreateHooks()
end)

function Nova_Logging_CreateHooks()
    -----------------------
    --Damage / Death Logs--
    -----------------------
    /*
    hook.Add("PostEntityTakeDamage","Nova Server Logging DamageHook", function(ent,dmgi,tookdamage)
        if(tookdamage == false) then return end
        
        if(ent:IsPlayer()) then
            damageentname = ent:GetName()
        else
            damageentname = ent:GetClass()
        end

        local dmg = dmgi:GetDamage()
        local attacker = dmgi:GetAttacker()
        local inflictor = tostring(dmgi:GetInflictor()) -- This will often return a weapon or the projectile that hit the ent
        local pos = tostring(ent:GetPos())

        if(attacker:IsPlayer()) then
            attackername = attacker:GetName()
        else
            attackername = attacker:GetClass()
        end

        if(attacker:IsPlayer() or attacker:IsNPC()) then
            damagehookweapon = tostring(attacker:GetActiveWeapon()) --This will not return the correct weapon if it was a projectile and they switch!

            DamageString = damageentname.." took "..dmg.." damage from "..attackername.." using "..damagehookweapon.." inflicted by "..inflictor.." at position "..pos
        else
            DamageString = damageentname.." took "..dmg.." damage from "..attackername.." inflicted by "..inflictor.." at position "..pos
        end

        local date = os.date("%d %m %Y",os.time())
        local time = os.date("%I:%M:%S%p",os.time())
        
        if(file.Exists("n_server_logs/damagelogs/log "..date..".txt","DATA")) then
            file.Append("n_server_logs/damagelogs/log "..date..".txt","\n"..time.." "..DamageString)
        else
            Nova_CheckLogFileDate()

            timer.Simple(0.1,function()
                file.Append("n_server_logs/damagelogs/log "..date..".txt","\n"..time.." "..DamageString)
            end)
        end
    end)
    */

    hook.Add("PlayerDeath","Nova Server Logging Deaths",function(ent,inflictor,attacker)
        local date = os.date("%d %m %Y",os.time())
        local time = os.date("%I:%M:%S%p",os.time())

        if(ent == attacker) then
            if(inflictor:GetClass() != "player") then
                DeathString = ent:GetName().." Committed Suicide using "..tostring(inflictor)
            else
                DeathString = ent:GetName().." Committed Suicide"
            end
        elseif(attacker:IsNPC()) then
            DeathString = ent:GetName().." was killed by "..tostring(inflictor)
        else
            DeathString = ent:GetName().." was killed by "..attacker:GetName().." using "..tostring(inflictor)
        end
        
        if(file.Exists("n_server_logs/damagelogs/log "..date..".txt","DATA")) then
            file.Append("n_server_logs/damagelogs/log "..date..".txt","\n"..time.." "..DeathString)
        else
            Nova_CheckLogFileDate()

            timer.Simple(0.1,function()
                file.Append("n_server_logs/damagelogs/log "..date..".txt","\n"..time.." "..DeathString)
            end)
        end
    end)

    ----------------------------
    --Chat / Join / Leave Logs--
    ----------------------------
    hook.Add("PlayerSay","Nova Server Logging Chat",function(sender,text,team)
        local date = os.date("%d %m %Y",os.time())
        local time = os.date("%I:%M:%S%p",os.time())

        if(team == true) then
            ChatString = "[TEAM] "..sender:GetName()..": "..text
        else
            ChatString = sender:GetName()..": "..text
        end

        if(file.Exists("n_server_logs/chatlogs/log "..date..".txt","DATA")) then
            file.Append("n_server_logs/chatlogs/log "..date..".txt","\n"..time.." "..ChatString)
        else
            Nova_CheckLogFileDate()

            timer.Simple(0.1,function()
                file.Append("n_server_logs/chatlogs/log "..date..".txt","\n"..time.." "..ChatString)
            end)
        end
    end)

    hook.Add("PlayerConnect","Nova Server Logging Player Join",function(name,ip)
        local date = os.date("%d %m %Y",os.time())
        local time = os.date("%I:%M:%S%p",os.time())

        local JoinString = name.." Joined the server from "..ip

        if(file.Exists("n_server_logs/chatlogs/log "..date..".txt","DATA")) then
            file.Append("n_server_logs/chatlogs/log "..date..".txt","\n"..time.." "..JoinString)
        else
            Nova_CheckLogFileDate()

            timer.Simple(0.1,function()
                file.Append("n_server_logs/chatlogs/log "..date..".txt","\n"..time.." "..JoinString)
            end)
        end
    end)

    hook.Add("PlayerDisconnected","Nova Server Logging Player Leave",function(ply)
        local date = os.date("%d %m %Y",os.time())
        local time = os.date("%I:%M:%S%p",os.time())

        local LeaveString = ply:GetName().." Left the server"

        if(file.Exists("n_server_logs/chatlogs/log "..date..".txt","DATA")) then
            file.Append("n_server_logs/chatlogs/log "..date..".txt","\n"..time.." "..LeaveString)
        else
            Nova_CheckLogFileDate()

            timer.Simple(0.1,function()
                file.Append("n_server_logs/chatlogs/log "..date..".txt","\n"..time.." "..LeaveString)
            end)
        end
    end)

    ---------------
    --Entity Logs--
    ---------------
    hook.Add("OnEntityCreated","Nova Server Logging Ent Created",function(ent)
        timer.Simple(0.1,function() --this is required because entities dont have most of their properties on the hook trigger
            if(IsValid(ent) and ent:GetClass() != "physgun_beam") then
                local date = os.date("%d %m %Y",os.time())
                local time = os.date("%I:%M:%S%p",os.time())

                if(IsValid(ent:GetCreator())) then
                    EntCreatedOwner = ent:GetCreator():GetName()
                else
                    EntCreatedOwner = "world"
                end
                
                local EntCreatedString = tostring(ent).." was created at "..tostring(ent:GetPos()).." by "..EntCreatedOwner

                if(file.Exists("n_server_logs/entitylogs/log "..date..".txt","DATA")) then
                    file.Append("n_server_logs/entitylogs/log "..date..".txt","\n"..time.." "..EntCreatedString)
                else
                    Nova_CheckLogFileDate()

                    timer.Simple(0.1,function()
                        file.Append("n_server_logs/entitylogs/log "..date..".txt","\n"..time.." "..EntCreatedString)
                    end)
                end
            end
        end)
    end)

    hook.Add("EntityRemoved","Nova Server Logging Ent Removed",function(ent,fupdate)
        if(IsValid(ent) and ent:GetClass() != "physgun_beam") then
            local date = os.date("%d %m %Y",os.time())
            local time = os.date("%I:%M:%S%p",os.time())

            if(IsValid(ent:GetCreator())) then
                EntRemovedOwner = ent:GetCreator():GetName()
            else
                EntRemovedOwner = "world"
            end
                
            local EntRemovedString = tostring(ent).." owned by "..EntRemovedOwner.." was removed at "..tostring(ent:GetPos())

            if(file.Exists("n_server_logs/entitylogs/log "..date..".txt","DATA")) then
                file.Append("n_server_logs/entitylogs/log "..date..".txt","\n"..time.." "..EntRemovedString)
            else
                Nova_CheckLogFileDate()

                timer.Simple(0.1,function()
                    file.Append("n_server_logs/entitylogs/log "..date..".txt","\n"..time.." "..EntRemovedString)
                end)
            end
        end
    end)

    hook.Add("OnCrazyPhysics","Nova Server Logging Crazy Phys",function(ent,physobj)
        local date = os.date("%d %m %Y",os.time())
        local time = os.date("%I:%M:%S%p",os.time())

        if(IsValid(ent:GetCreator())) then
            EntPhysOwner = ent:GetCreator():GetName()
        else
            EntPhysOwner = "world"
        end

        local EntPhysString = tostring(ent).." owned by "..EntPhysOwner.." was removed at "..tostring(ent:GetPos()).." because of crazy physics.")

        if(file.Exists("n_server_logs/entitylogs/log "..date..".txt","DATA")) then
            file.Append("n_server_logs/entitylogs/log "..date..".txt","\n"..time.." "..EntPhysString)
        else
            Nova_CheckLogFileDate()

            timer.Simple(0.1,function()
                file.Append("n_server_logs/entitylogs/log "..date..".txt","\n"..time.." "..EntPhysString)
            end)
        end
    end)

    /*
    ------------
    --Use Logs--
    ------------
    hook.Add("","Nova Server Logging Use",function()

    end)
    */
end
end --server end