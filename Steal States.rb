#==============================================================================
# 
# �� Yami Engine Symphony - Steal States
# -- Last Updated: 2012.12.16
# -- Level: Easy
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YES-StealStates"] = true

#==============================================================================
# �� Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.12.16 - Started and Finished Script.
# 
#==============================================================================
# �� Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides steal states ability for battlers.
#
#==============================================================================
# �� Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below �� Materials/�f�� but above �� Main. Remember to save.
#
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skill notebox in the database.
# -----------------------------------------------------------------------------
# <steal allow: x, x, x>
# Limits states id that skill can steal. Replace x with state ID.
#
# <steal n states: string>
# Steals n states from target. String can be:
#   last states
#   high priority
#   low priority
#
#==============================================================================
# �� Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjustments.
# 
#==============================================================================

#==============================================================================
# �� Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# �� Regular Expression
#==============================================================================

module REGEXP
  module STEAL_STATES
    STEAL_ALLOW = /<(?:STEAL_ALLOW|steal allow):[ ]*(.*)>/i
    STEAL_STATE = /<(?:STEAL (\d+) STATES):[ ]*(.*)>/i
  end # STEAL_STATES
end # REGEXP

#==============================================================================
# �� DataManager
#==============================================================================

module DataManager
    
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_steal_states load_database; end
  def self.load_database
    load_database_steal_states
    initialize_steal_states
  end
  
  #--------------------------------------------------------------------------
  # new method: initialize_steal_states
  #--------------------------------------------------------------------------
  def self.initialize_steal_states
    groups = [$data_skills, $data_items]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.initialize_steal_states
      }
    }
  end
  
end # DataManager

#==============================================================================
# �� RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :steal_allow
  attr_accessor :steal_states

  #--------------------------------------------------------------------------
  # new method: initialize_steal_states
  #--------------------------------------------------------------------------
  def initialize_steal_states
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::STEAL_STATES::STEAL_ALLOW
        @steal_allow ||= []
        $1.scan(/\d+/).each { |id| @steal_allow.push(id.to_i) }
      when REGEXP::STEAL_STATES::STEAL_STATE
        @steal_states = [$1.to_i, $2.to_s]
      end
    }
  end
  
end # RPG::BaseItem

#==============================================================================
# �� Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # alias method: item_test
  #--------------------------------------------------------------------------
  alias yes_steal_states_item_test item_test
  def item_test(user, item)
    return true if stealing_states(user, item).size > 0
    return yes_steal_states_item_test(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_apply
  #--------------------------------------------------------------------------
  alias yes_steal_states_item_user_effect item_user_effect
  def item_user_effect(user, item)
    item_effect_steal_states(user, item)
    yes_steal_states_item_user_effect(user, item)
  end
  
  #--------------------------------------------------------------------------
  # new method: item_effect_steal_states
  #--------------------------------------------------------------------------
  def item_effect_steal_states(user, item)
    return unless @result.hit?
    return unless item.steal_states
    @result.success = true
    hash = stealing_states(user, item)
    hash.each { |id|
      self.remove_state(id)
      user.add_state(id)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: stealing_states
  #--------------------------------------------------------------------------
  def stealing_states(user, item)
    return [] unless item.steal_states
    result = []
    hash = item.steal_states
    allow = item.steal_allow
    states_hash = self.states
    #---
    case hash[1].upcase
    when "last", "last states", "last state"
      states_hash = self.result.added_states.reverse
    when "low", "low priority", "lower priority"
      states_hash.reverse!
    when "random"
      states_hash.shuffle!
    end
    #---
    states_hash.each { |state|
      next if allow && !allow.include?(state.id)
      result.push(state.id) unless result.include?(state.id)
      break if result.size >= hash[0]
    }
    return result
  end

end # Game_Battler

#==============================================================================
# 
# �� End of File
# 
#==============================================================================