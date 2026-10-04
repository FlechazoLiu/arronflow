local function markdown_to_pdf()
  local input = vim.api.nvim_buf_get_name(0)
  if input == "" then
    vim.notify("Markdown to PDF: save the file first", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update")
  local output = vim.fn.fnamemodify(input, ":r") .. ".pdf"

  vim.system({
    "pandoc",
    input,
    "--from=markdown",
    "--output=" .. output,
    "--pdf-engine=xelatex",
    "--variable=CJKmainfont=PingFang SC",
  }, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Markdown PDF created: " .. output)
      else
        local message = result.stderr and result.stderr:match("[^\r\n]+") or "unknown error"
        vim.notify("Markdown to PDF failed: " .. message, vim.log.levels.ERROR)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_pdf", { clear = true }),
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "<leader>mp", markdown_to_pdf, {
      buffer = event.buf,
      desc = "Markdown to PDF",
    })
  end,
})

return {}
