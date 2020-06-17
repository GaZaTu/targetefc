local addonName, addonData = ...

local red = function(text)
  return format('|cFFFF0000%s|r', text)
end

local L = setmetatable({}, {
  __index = function(L, key)
    print(red(format('TargetEFC: "%s" localization for "%s" is missing', GetLocale(), key)))

    return nil
  end,
})

addonData.L = L
