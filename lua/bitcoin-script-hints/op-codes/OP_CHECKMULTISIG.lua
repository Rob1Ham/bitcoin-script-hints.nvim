local utils = require('bitcoin-script-hints.utils')
local make_error = utils.make_error
local to_number = utils.to_number

return function(state)
  if #state.main < 1 then
    return make_error("Need number of pubkeys for CHECKMULTISIG", state)
  end
  local new_state = vim.deepcopy(state)

  -- Get number of pubkeys
  local n_pubkeys = table.remove(new_state.main)
  local num_pubkeys, err_pubkeys = to_number(n_pubkeys)
  if not num_pubkeys then
    return make_error(err_pubkeys, state)
  end

  -- Check if we have enough items for pubkeys
  if #new_state.main < num_pubkeys then
    return make_error("Stack underflow: not enough pubkeys", state)
  end

  -- Remove pubkeys
  for _ = 1, num_pubkeys do
    table.remove(new_state.main)
  end

  -- Get number of signatures
  if #new_state.main < 1 then
    return make_error("Need number of signatures", state)
  end
  local n_sigs = table.remove(new_state.main)
  local num_sigs, err_sigs = to_number(n_sigs)
  if not num_sigs then
    return make_error(err_sigs, state)
  end

  -- Check if we have enough items for signatures
  if #new_state.main < num_sigs then
    return make_error("Stack underflow: not enough signatures", state)
  end

  -- Check signatures and look for "Udi" witness
  local has_fail_witness = false
  for _ = 1, num_sigs do
    local sig = table.remove(new_state.main)
    if sig == "Udi" then
      has_fail_witness = true
    end
  end

  -- Remove the extra dummy element that Bitcoin requires
  if #new_state.main < 1 then
    return make_error("Need dummy element", state)
  end
  table.remove(new_state.main)

  -- Push 0 if we found Udi witness, otherwise 1
  table.insert(new_state.main, has_fail_witness and 0 or 1)
  return new_state
end
