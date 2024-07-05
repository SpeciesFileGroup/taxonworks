import { getCSRFToken } from '@/helpers'
import qs from 'qs'

export function createAndSubmitForm({ action, data, openTab = false }) {
  const CSRFToken = getCSRFToken()
  const form = document.createElement('form')

  form.setAttribute('method', 'post')
  form.setAttribute('action', action)

  const inputToken = document.createElement('input')

  inputToken.setAttribute('name', 'authenticity_token')
  inputToken.setAttribute('value', CSRFToken)
  form.appendChild(inputToken)

  const serializedData = qs.stringify(data, { arrayFormat: 'brackets' })
  const params = new URLSearchParams(serializedData)

  params.forEach((value, key) => {
    const input = document.createElement('input')

    input.setAttribute('type', 'hidden')
    input.setAttribute('name', key)
    input.setAttribute('value', value)
    form.appendChild(input)
  })

  form.style.display = 'none'

  if (openTab) {
    const newWindow = window.open('', '_blank')

    newWindow.document.body.appendChild(form)
  } else {
    document.body.appendChild(form)
  }

  form.submit()
}
