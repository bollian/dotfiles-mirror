local dap = require 'dap'
local dapui = require 'dapui'
local hydra = require 'hydra'
local dap_python = require 'dap-python'
local M = {}

dap.adapters.python = {
    type = 'executable',
    command = 'python3',
    args = {'-m', 'debugpy.adapter'}
}

dap.adapters.cpp = {
    type = 'executable',
    name = 'lldb-cpp',
    command = 'lldb-vscode-11',
    args = {},
    attach = {
        pidProperty = "processId",
        pidSelect = "ask"
    },
    env = {
        LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
    }
}

-- create a tab for the debug UI if it doesn't exist
-- switch to that tab if it's not currently open
-- close that tab if it is currently open
vim.api.nvim_create_user_command('DapUi', function(state)
  if dap_tabpage == nil then
    vim.cmd 'tab split'
    vim.t.guitablabel = 'Debug'
    dap_tabpage = vim.api.nvim_get_current_tabpage()
    dapui.open()
  elseif dap_tabpage == vim.api.nvim_get_current_tabpage() then
    M.close_dap()
  else
    vim.api.nvim_set_current_tabpage(dap_tabpage)
  end
end, {})

M.close_dap = function()
  if dap_tabpage ~= nil then
    vim.api.nvim_set_current_tabpage(dap_tabpage)
    dapui.close()
    vim.cmd 'tabclose'
    dap_tabpage = nil
  end
end

dap_python.test_runner = 'pytest'


-- debug mode with dedicated keymaps
local function conditional_bp()
  dap.set_breakpoint(vim.fn.input('Condition: '))
end

local function logpoint()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log message: '))
end

local function debug_test()
  if vim.bo.filetype == 'python' then
    dap_python.test_method()
  else
    print(vim.bo.filetype .. ' has no "debug unit test" keymap set')
  end
end

local function debug_fixture()
  if vim.bo.filetype == 'python' then
    dap_python.test_method()
  else
    print(vim.bo.filetype .. ' has no "debug test fixture" keymap set')
  end
end

local function debug_selection()
  if vim.bo.filetype == 'python' then
    dap_python.debug_selection()
  else
    print(vim.bo.filetype .. ' has no "debug test fixture" keymap set')
  end
end

local function test_selection()
  if vim.bo.filetype == 'python' then
    dap_python.test_selection()
  else
    print(vim.bo.filetype .. ' has no "debug selection" keymap set')
  end
end

local hint = [[

 _c_: Continue/start      _t_: Debug test
 _n_: Next                _F_: Debug fixture
 _s_: Step                _v_: Debug selection 
 _f_: Finish function     _r_: Rerun previous
 _b_: Toggle break        _R_: Open REPL
 _B_: Conditional break   _q_: Quit session
 _l_: Logpoint
                    _<esc>_

]]
hydra({
  name = 'Debug',
  mode = 'n',
  body = '<leader>d',
  hint = hint,
  config = {
    color = 'pink',
    invoke_on_body = true,
    hint = {
      type = 'window',
      position = 'middle-right',
    },
  },
  heads = {
    { 'c', dap.continue, { desc = 'Continue or start until next breakpoint' } },
    { 'n', dap.step_over, { desc = 'Step over, not entering functions' } },
    { 's', dap.step_into, { desc = 'Step into, entering any functions' } },
    { 'f', dap.step_out, { desc = 'Step out, finishing current function' } },
    { 'b', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' } },
    { 'B', conditional_bp, { desc = 'Set conditional breakpoint' } },
    { 'l', logpoint, { desc = 'Set logpoint' } },
    { 't', debug_test, { desc = 'Debug the hovered test function' } },
    { 'F', debug_fixture, { desc = 'Debug the hovered test fixture' } },
    { 'v', debug_selection, { desc = 'Debug the highlighted code', } },
    { 'r', dap.run_last, { desc = 'Rerun previous configuration' } },
    { 'R', dap.repl.open, { desc = 'Open REPL' } },
    { 'q', dap.terminate, { desc = 'Kill current session', exit = true } },
    { '<esc>', nil, { exit = true } },
  },
})

return M
