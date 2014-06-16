﻿#==============================================================================
# 
# ▼ YSA Battle Add-On: Spread State
# -- Last Updated: 2011.12.14
# -- Level: Easy
# -- Requires: none
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-SpreadState"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.14 - Started Script and Finished.
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# When you use a "spread state" Skill, it will spread a or some state from target
# to other battler (allies and/or enemies).
# 
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skill notebox in the database.
# -----------------------------------------------------------------------------
# <spread ally: x, y, z>
# This skill will spread states x, y, z from the target to all allies. Can use
# as many as states' ID in this tag. 
# Example: <spread ally: 1, 2, 3, 4, 5, 6>
#
# <spread enemy: x, y, z>
# This skill will spread states x, y, z from the target to all enemies. Can use
# as many as states' ID in this tag. 
# Example: <spread enemy: 1, 2, 3, 4, 5, 6>
#
# <spread ally all>
# This skill will spread all states from the target to all allies.
#
# <spread enemy all>
# This skill will spread all states from the target to all enemies.
# 
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

module YSA
  module REGEXP
  module STATE
    
    SPREAD_ALLY = /<(?:SPREAD_ALLY|spread ally):[ ](\d+(?:\s*,\s*\d+)*)>/i
    SPREAD_ENEMY = /<(?:SPREAD_ENEMY|spread enemy):[ ](\d+(?:\s*,\s*\d+)*)>/i
    SPREAD_ALLY_ALL = /<(?:SPREAD_ALLY_ALL|spread ally all)>/i
    SPREAD_ENEMY_ALL = /<(?:SPREAD_ENEMY_ALL|spread enemy all)>/i
    
  end # STATE
  end # REGEXP
end # YSA

#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_sprstate load_database; end
  def self.load_database
    load_database_sprstate
    load_notetags_sprstate
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_sprstate
  #--------------------------------------------------------------------------
  def self.load_notetags_sprstate
    groups = [$data_skills]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_sprstate
      end
    end
  end
  
end # DataManager

#==============================================================================
# ■ RPG::Skill
#==============================================================================

class RPG::Skill < RPG::UsableItem
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :state_spread_ally
  attr_accessor :state_spread_enemy
  
  #--------------------------------------------------------------------------
  # common cache: load_notetags_sprstate
  #--------------------------------------------------------------------------
  def load_notetags_sprstate
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YSA::REGEXP::STATE::SPREAD_ALLY_ALL
        @state_spread_ally = -1
      when YSA::REGEXP::STATE::SPREAD_ENEMY_ALL
        @state_spread_enemy = -1
      when YSA::REGEXP::STATE::SPREAD_ALLY
        @state_spread_ally = [] if @state_spread_ally == nil
        $1.scan(/\d+/).each do |i|
          @state_spread_ally.push(i.to_i)
        end
      when YSA::REGEXP::STATE::SPREAD_ENEMY
        @state_spread_enemy = [] if @state_spread_enemy == nil
        $1.scan(/\d+/).each do |i|
          @state_spread_enemy.push(i.to_i)
        end
      end
    } # self.note.split
    #---
  end
  
end # RPG::State

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # alias method: apply_item_effects
  #--------------------------------------------------------------------------
  alias spread_state_apply_item_effects apply_item_effects
  def apply_item_effects(target, item)
    spread_state_apply_item_effects(target, item)
    
    if item.state_spread_ally != nil
      for state in target.states
        for battler in $game_party.members
          battler.add_state(state.id) if item.state_spread_ally == -1 || item.state_spread_ally.include?(state.id)
        end
      end
    end
    
    if item.state_spread_enemy != nil
      for state in target.states
        for battler in $game_troop.members
          battler.add_state(state.id) if item.state_spread_enemy == -1 || item.state_spread_enemy.include?(state.id)
        end
      end
    end
    
  end

end

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================