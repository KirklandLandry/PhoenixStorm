
local musicPath = "assets/audio/music/"
local fxPath = "assets/audio/fx/"
audioSources ={
    stage1 = musicPath.."stage1.wav",
    boss1 = musicPath.."boss1.wav",
    smallExplosion = fxPath.."smallExplosion1.wav",
    shoot = fxPath.."shoot.wav",
    scoreToken = fxPath.."Picked Coin Echo.wav",
    rumble = fxPath.."rumble.wav",
    rumbleComplete = fxPath.."rumbleComplete.wav",
}



-- https://github.com/sonic2kk/SPAM
spam = {}

spam.version = 2.0

function spam_newmanager(name)
    local i = {
        name = name,
        audio = {},
    }

    table.insert(spam, i)
end

function spam_newsource(mname, sname, path, type)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname] = love.audio.newSource(path, type)
        end
    end
end

function spam_removesource(mnane, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            table.remove(v.audio, sname)
        end
    end
end

function spam_setloopsource(mname, sname, loop)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:setLooping(loop)
        end
    end
end

function spam_setvolume(mname, sname, vol)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:setVolume(vol)
        end
    end
end

function spam_getvolume(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            return v.audio[sname]:getVolume()
        end
    end
end

function spam_stopsource(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:stop()
        end
    end
end

function spam_playsource(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:play()
        end
    end
end

function spam_pausesource(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:pause()
        end
    end
end

function spam_getsource(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            return v.audio[sname]
        end
    end
end

function spam_resumesource(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:resume()
        end
    end
end

function spam_issourceplaying(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:isPlaying()
        end
    end
end

function spam_issourcelooping(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            v.audio[sname]:isLooping()
        end
    end
end

function spam_isstatic(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            return v.audio[sname]:isStatic()
        end
    end
end

function spam_getposition(mname, sname, unit)
    for i,v in ipairs(spam) do
        if v.name == mname then
            return v.audio[sname]:tell(unit)
        end
    end
end

function spam_ispaused(mname, sname)
    for i,v in ipairs(spam) do
        if v.name == mname then
            return v.audio[sname]:isPaused()
        end
    end
end

function spam_getversion()
    return spam.version
end





-- https://love2d.org/wiki/Minimalist_Sound_Manager
-- will hold the currently playing sources
local sources = {}
local audioUpdateTime = 0
local lastScoreTokenPlayTime = 0
local currentScoreTokenAudioLevel = 1
local currentScoreTokenAudioLevelDecrement = 0.04
local currentScoreTokenAudioLevelThreshold = 0.02
-- check for sources that finished playing and remove them
-- add to love.update
function love.audio.update(dt)
    audioUpdateTime = audioUpdateTime + dt
    if audioUpdateTime - lastScoreTokenPlayTime > currentScoreTokenAudioLevelThreshold then
        currentScoreTokenAudioLevel = 1
    end 

    local remove = {}
    for _,s in pairs(sources) do
        if s:isStopped() then
            remove[#remove + 1] = s
        end
    end

    for i,s in ipairs(remove) do
        sources[s] = nil
    end
end

-- overwrite love.audio.play to create and register source if needed
local play = love.audio.play
function love.audio.play(what, how, loop)
    local src = what
    if type(what) ~= "userdata" or not what:typeOf("Source") then



        src = love.audio.newSource(what, how)
        src:setLooping(loop or false)

        -- to prevent collecting too many score tokens and clipping the audio
        if what == audioSources.scoreToken then 
            if audioUpdateTime - lastScoreTokenPlayTime < currentScoreTokenAudioLevelThreshold then 
                --print("dev"..tostring(currentScoreTokenAudioLevel))
                currentScoreTokenAudioLevel = currentScoreTokenAudioLevel - currentScoreTokenAudioLevelDecrement
                if currentScoreTokenAudioLevel < 0.05 then 
                    currentScoreTokenAudioLevel = 0.5
                end 
                src:setVolume(currentScoreTokenAudioLevel)
            else 
                currentScoreTokenAudioLevel = 1
                --print("reset")
            end 
            lastScoreTokenPlayTime = audioUpdateTime
        end 
    end

    play(src)
    sources[src] = src
    return src
end

-- stops a source
local stop = love.audio.stop
function love.audio.stop(src)
    if not src then return end
    stop(src)
    sources[src] = nil
end

