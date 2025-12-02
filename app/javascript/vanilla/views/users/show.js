function handleToggleButton() {
  const input = document.getElementById('tokenInput')
  const isVisible = input.type == 'text'

  input.type = isVisible ? 'password' : 'text'
}

function handleClipboardButton() {
  const input = document.getElementById('tokenInput')

  navigator.clipboard.writeText(input.value)
  TW.workbench.alert.create('API Token copied to clipboard', 'notice')
}

function handleEmailCopy(e) {
  console.log(e.target)
  navigator.clipboard.writeText(e.target.textContent)
  TW.workbench.alert.create('Email copied to clipboard', 'notice')
}

function initialize() {
  const toggleBtn = document.getElementById('toggle-token-btn')
  const copyBtn = document.getElementById('copy-token-btn')
  const emailEl = document.getElementById('user-email')

  toggleBtn?.removeEventListener('click', handleToggleButton)
  toggleBtn?.addEventListener('click', handleToggleButton)
  copyBtn?.removeEventListener('click', handleClipboardButton)
  copyBtn?.addEventListener('click', handleClipboardButton)
  emailEl?.removeEventListener('click', handleEmailCopy)
  emailEl?.addEventListener('click', handleEmailCopy)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#user-profile')) {
    initialize()
  }
})
