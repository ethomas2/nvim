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

  print('[DEBUG] Step 1: Ciphertext from selection')
  print('[DEBUG] Ciphertext: ', ciphertext)
  print('[DEBUG] First 50 chars: ' .. ciphertext:sub(1, 50))
  print('[DEBUG] Last 50 chars: ' .. ciphertext:sub(-50))

  -- Get passphrase using inputsecret
  local passphrase = get_passphrase()

  if not passphrase or passphrase == '' then
    vim.notify('Decryption cancelled: no passphrase provided', vim.log.levels.WARN)
    return
  end

  print('[DEBUG] Step 2: Passphrase received')
  print('[DEBUG] Passphrase length: ' .. #passphrase)

  -- Step 1: Write ciphertext to temp file for base64 decode
  local temp_cipher = os.tmpname()
  local f = io.open(temp_cipher, 'w')
  f:write(ciphertext)
  f:close()

  print('[DEBUG] Step 3: Wrote ciphertext to temp file: ' .. temp_cipher)

  -- Step 2: Base64 decode
  local temp_decoded = os.tmpname()
  local base64_cmd = string.format('base64 -d < %s > %s 2>&1',
    vim.fn.shellescape(temp_cipher),
    vim.fn.shellescape(temp_decoded))

  print('[DEBUG] Step 4: Running base64 decode')
  print('[DEBUG] Command: ' .. base64_cmd)

  local base64_handle = io.popen(base64_cmd)
  local base64_output = base64_handle:read('*a')
  local base64_success = base64_handle:close()

  if base64_output ~= '' then
    print('[DEBUG] Base64 stderr/stdout: ' .. base64_output)
  end

  -- Check decoded file size
  local decoded_file = io.open(temp_decoded, 'r')
  if not decoded_file then
    print('[DEBUG] ERROR: Failed to open decoded file')
    os.remove(temp_cipher)
    vim.notify('Base64 decode failed', vim.log.levels.ERROR)
    return
  end

  local decoded_size = decoded_file:seek('end')
  decoded_file:close()
  print('[DEBUG] Decoded file size: ' .. decoded_size .. ' bytes')

  -- Step 3: GPG decrypt
  print('[DEBUG] Step 5: Running GPG decrypt')
  local gpg_cmd = string.format(
    'gpg --batch --passphrase %s --no-symkey-cache -d < %s 2>&1',
    vim.fn.shellescape(passphrase),
    vim.fn.shellescape(temp_decoded)
  )
  print('[DEBUG] GPG command: ' .. gpg_cmd:gsub(vim.fn.shellescape(passphrase), '[PASSPHRASE]'))

  local gpg_handle = io.popen(gpg_cmd)
  local plaintext = gpg_handle:read('*a')
  local gpg_success = gpg_handle:close()

  -- Clean up temp files
  os.remove(temp_cipher)
  os.remove(temp_decoded)

  print('[DEBUG] Step 6: GPG output')
  print('[DEBUG] Output length: ' .. #plaintext)
  print('[DEBUG] GPG exit success: ' .. tostring(gpg_success))

  if not gpg_success or plaintext == '' then
    print('[DEBUG] ERROR: Decryption failed')
    vim.notify('Decryption failed: ' .. plaintext, vim.log.levels.ERROR)
    return
  end

  -- Show decrypted text in vim messages (not in buffer)
  vim.notify('Decrypted text: ' .. plaintext, vim.log.levels.INFO)
  print('[DEBUG] === DECRYPTION COMPLETE ===')
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
