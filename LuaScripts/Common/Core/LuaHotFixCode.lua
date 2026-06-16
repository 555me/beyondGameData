_G.__enableHotfixLua__ = true

_G.__enableHotfixLua2__ = true

_G.__enableHotfixLua3__ = true

_G.__enableHotfixLua4__ = true

local uiCtrl = require_ex('UI/Panels/Base/UICtrl')
local phaseBase = require_ex('Phase/Core/PhaseBase')



local oldWeaponExhibitUpgradeCtrl = require_ex('UI/Panels/SimulationTraining/SimulationTrainingCtrl')
SimulationTrainingCtrl = HL.Class('SimulationTrainingCtrl', uiCtrl.UICtrl)

SimulationTrainingCtrl._OnClickGiveUpBtn = HL.Method() << function(self)
    local m_system = GameInstance.player.simulationTrainingSystem
    if self.m_unlimitedMode then
        
        m_system:SimulationTrainingGiveUp()
        return
    end

    if m_system.dailyFoldCnt > 0 then
        Notify(MessageConst.SHOW_POP_UP, {
            content = string.format(
                Language.LUA_SIMULATION_TRAINING_GIVE_UP_POPUP_HAVE_EXIT, m_system.dailyFoldCnt
            ), 
            subContent = "",
            onConfirm = function()
                m_system:SimulationTrainingGiveUp()
            end,
            onCancel = nil,
            confirmText = Language.LUA_SIMULATION_TRAINING_POPUP_CONFIRM_TEXT, 
            cancelText = Language.LUA_SIMULATION_TRAINING_POPUP_CANCEL_TEXT,   
        })
    else
        Notify(MessageConst.SHOW_POP_UP, {
            content = "<color=#FF0000>" .. Language.LUA_SIMULATION_TRAINING_GIVE_UP_POPUP_NO_EXIT .. "</color>", 
            subContent = "",
            onConfirm = function()
                m_system:SimulationTrainingGiveUp()
            end,
            onCancel = nil,
            confirmText = Language.LUA_SIMULATION_TRAINING_POPUP_CONFIRM_TEXT,
            cancelText = Language.LUA_SIMULATION_TRAINING_POPUP_CANCEL_TEXT,
        })
    end
end
HL.Commit(SimulationTrainingCtrl)


