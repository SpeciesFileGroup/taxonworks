function initialize() {
  const gen = document.querySelector(
    "input[name='project[set_new_api_access_token]']"
  )
  const clr = document.querySelector(
    "input[name='project[clear_api_access_token]']"
  )

  gen.addEventListener('change', () => {
    if (gen.checked) clr.checked = false
  })

  clr.addEventListener('change', () => {
    if (clr.checked) gen.checked = false
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#project-new')) {
    initialize()
  }
})
