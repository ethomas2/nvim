local M = {}

-- Get passphrase using built-in inputsecret (never stored to disk)
local function get_passphrase()
  local passphrase = vim.fn.inputsecret('Enter passphrase: ')
  -- Trim any whitespace/newlines
  return passphrase:match('^%s*(.-)%s*$')
end

-- Encrypt selected text
function M.encrypt_selection()
  -- Get visual selection marks
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Get visual selection using built-in function
  local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.visualmode() })

  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
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


function M.decrypt_selection()
  -- Get visual selection using built-in function
  local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.visualmode() })
  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
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

  -- Step 1: Base64 decode (binary mode, stdin -> stdout)
  local b64_proc_handle = vim.system({ 'base64', '-d' }, { stdin = ciphertext_b64, text = false }):wait()
  if b64_proc_handle.code ~= 0 or b64_proc_handle.stdout == '' then
    vim.notify('Base64 decode failed: ' .. (b64_proc_handle.stderr or 'unknown error'), vim.log.levels.ERROR)
    return
  end
  local ciphertext_raw = b64_proc_handle.stdout

  -- Step 2: GPG decrypt (binary mode, pass decoded data via stdin)
  local gpg_result = vim.system(
    { 'gpg', '--batch', '--passphrase', passphrase, '--no-symkey-cache', '-d' },
    { stdin = ciphertext_raw, text = false }
  ):wait()

  if gpg_result.code ~= 0 then
    local error_msg = gpg_result.stderr or gpg_result.stdout or 'unknown error'
    vim.notify('Decryption failed: ' .. error_msg, vim.log.levels.ERROR)
    return
  end

  local plaintext = gpg_result.stdout

  if plaintext == '' then
    vim.notify('Decryption failed: empty output', vim.log.levels.ERROR)
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
