local M = {}

-- Get passphrase using built-in inputsecret (never stored to disk)
local function get_passphrase()
  local passphrase = vim.fn.inputsecret('Enter passphrase: ')
  -- Trim any whitespace/newlines
  return passphrase:match('^%s*(.-)%s*$')
end

local function get_range_lines(command_opts)
  if not command_opts or command_opts.range == 0 then
    return nil, nil, nil, 'No range selected'
  end

  local start_line = math.min(command_opts.line1, command_opts.line2)
  local end_line = math.max(command_opts.line1, command_opts.line2)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    return nil, nil, nil, 'No text selected'
  end

  return lines, start_line, end_line, nil
end

local function gpg_error_message(prefix, proc_result)
  local stderr = proc_result.stderr or ''
  stderr = stderr:gsub('%s+$', '')

  if stderr == '' then
    return prefix
  end

  return prefix .. ': ' .. stderr
end

-- Encrypt the command range.
function M.encrypt_selection(command_opts)
  local lines, start_line, end_line, range_error = get_range_lines(command_opts)

  if range_error then
    vim.notify(range_error, vim.log.levels.WARN)
    return
  end

  local plaintext = table.concat(lines, '\n')

  -- Get passphrase using inputsecret
  local passphrase = get_passphrase()

  if not passphrase or passphrase == '' then
    vim.notify('Encryption cancelled: no passphrase provided', vim.log.levels.WARN)
    return
  end

  local proc_result = vim.system(
    {
      'gpg',
      '-c',
      '--batch',
      '--pinentry-mode',
      'loopback',
      '--passphrase',
      passphrase,
      '--no-symkey-cache',
    },
    { stdin = plaintext, text = false }
  ):wait()

  if proc_result.code ~= 0 or proc_result.stdout == '' then
    vim.notify(gpg_error_message('Encryption failed', proc_result), vim.log.levels.ERROR)
    return
  end

  local ciphertext = vim.base64.encode(proc_result.stdout)

  -- Replace selection with ciphertext
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {ciphertext})

  vim.notify('Text encrypted successfully', vim.log.levels.INFO)
end


function M.decrypt_selection(command_opts)
  local lines, _, _, range_error = get_range_lines(command_opts)

  if range_error then
    vim.notify(range_error, vim.log.levels.WARN)
    return
  end

  local ciphertext_b64 = table.concat(lines, '\n')
  ciphertext_b64 = ciphertext_b64:gsub('%s+', '')

  -- Get passphrase using inputsecret
  local passphrase = get_passphrase()
  if not passphrase or passphrase == '' then
    vim.notify('Decryption cancelled: no passphrase provided', vim.log.levels.WARN)
    return
  end

  local decode_success, ciphertext_raw = pcall(vim.base64.decode, ciphertext_b64)
  if not decode_success or not ciphertext_raw or ciphertext_raw == '' then
    vim.notify('Base64 decode failed', vim.log.levels.ERROR)
    return
  end

  local proc_result = vim.system(
    {
      'gpg',
      '--batch',
      '--pinentry-mode',
      'loopback',
      '--passphrase',
      passphrase,
      '--no-symkey-cache',
      '-d',
    },
    { stdin = ciphertext_raw, text = false }
  ):wait()

  if proc_result.code ~= 0 then
    vim.notify(gpg_error_message('Decryption failed', proc_result), vim.log.levels.ERROR)
    return
  end

  local plaintext = proc_result.stdout

  if plaintext == '' then
    vim.notify('Decryption failed: empty output', vim.log.levels.ERROR)
    return
  end

  -- Show decrypted text in vim messages (not in buffer)
  vim.notify('Decrypted text: ' .. plaintext, vim.log.levels.INFO)
end

-- Setup commands
function M.setup()
  vim.api.nvim_create_user_command('Encrypt', function(command_opts)
    M.encrypt_selection(command_opts)
  end, { range = true })

  vim.api.nvim_create_user_command('Decrypt', function(command_opts)
    M.decrypt_selection(command_opts)
  end, { range = true })
end

return M
