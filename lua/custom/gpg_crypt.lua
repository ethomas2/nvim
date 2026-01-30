local M = {}

-- Get passphrase using built-in inputsecret (never stored to disk)
local function get_passphrase()
  local passphrase = vim.fn.inputsecret('Enter passphrase: ')
  -- Trim any whitespace/newlines
  return passphrase:match('^%s*(.-)%s*$')
end

-- Encrypt selected text
function M.encrypt_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  -- Get selected text
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  -- Handle single line or multi-line selection
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  local plaintext = table.concat(lines, '\n')

  -- Get passphrase using inputsecret
  local passphrase = get_passphrase()

  if not passphrase or passphrase == '' then
    vim.notify('Encryption cancelled: no passphrase provided', vim.log.levels.WARN)
    return
  end

  -- Encrypt using GPG (passphrase never touches disk)
  local cmd = string.format(
    'export GPG_TTY=$(tty); echo -n %s | gpg -c --batch --passphrase %s --no-symkey-cache 2>/dev/null | base64',
    vim.fn.shellescape(plaintext),
    vim.fn.shellescape(passphrase)
  )

  local handle = io.popen(cmd)
  local ciphertext = handle:read('*a')
  local success = handle:close()

  if not success or ciphertext == '' then
    vim.notify('Encryption failed', vim.log.levels.ERROR)
    return
  end

  -- Remove trailing newline
  ciphertext = ciphertext:gsub('\n$', '')

  -- Replace selection with ciphertext
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {ciphertext})

  vim.notify('Text encrypted successfully', vim.log.levels.INFO)
end

-- Decrypt selected text and show in messages
function M.decrypt_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  -- Get selected text
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  -- Handle single line or multi-line selection
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  local ciphertext = table.concat(lines, '\n')

  -- Remove all whitespace and newlines from ciphertext (base64 can span multiple lines)
  ciphertext = ciphertext:gsub('%s+', '')

  -- Get passphrase using inputsecret
  local passphrase = get_passphrase()

  if not passphrase or passphrase == '' then
    vim.notify('Decryption cancelled: no passphrase provided', vim.log.levels.WARN)
    return
  end

  -- Decrypt using GPG (passphrase never touches disk)
  -- Note: shellescape adds quotes, so don't add manual quotes
  local cmd = string.format(
    'echo -n %s | base64 -d | gpg --batch --passphrase %s --no-symkey-cache -d 2>/dev/null',
    vim.fn.shellescape(ciphertext),
    vim.fn.shellescape(passphrase)
  )

  local handle = io.popen(cmd)
  local plaintext = handle:read('*a')
  local success = handle:close()

  if not success or plaintext == '' then
    vim.notify('Decryption failed: wrong passphrase or invalid ciphertext', vim.log.levels.ERROR)
    return
  end

  -- Show decrypted text in vim messages (not in buffer)
  vim.notify('Decrypted text: ' .. plaintext, vim.log.levels.INFO)
end

-- Setup commands
function M.setup()
  vim.api.nvim_create_user_command('Encrypt', function()
    M.encrypt_selection()
  end, { range = true })

  vim.api.nvim_create_user_command('Decrypt', function()
    M.decrypt_selection()
  end, { range = true })
end

return M
