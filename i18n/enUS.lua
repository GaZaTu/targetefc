local addonName, addonData = ...

local L = addonData.L

if GetLocale() == 'enUS' then
  L.MSG_BATTLE_FOR_WSG_1MIN = 'The battle for Warsong Gulch begins in 1 minute.'
  L.MSG_ALLIANCE_WINS = 'The Alliance wins!'
  L.MSG_HORDE_WINS = 'The Horde wins!'
  L.MSG_PATTERN_ALLIANCE_FLAG_PICKED = 'The Alliance Flag was picked up by ([^!]+)!'
  L.MSG_PATTERN_ALLIANCE_FLAG_DROPPED = 'The Alliance Flag was dropped by ([^!]+)!'
  L.MSG_PATTERN_ALLIANCE_FLAG_CAPTURED = '([^ ]+) captured the Alliance flag!'
  L.MSG_PATTERN_HORDE_FLAG_PICKED = 'The Horde flag was picked up by ([^!]+)!'
  L.MSG_PATTERN_HORDE_FLAG_DROPPED = 'The Horde flag was dropped by ([^!]+)!'
  L.MSG_PATTERN_HORDE_FLAG_CAPTURED = '([^ ]+) captured the Horde flag!'
end
