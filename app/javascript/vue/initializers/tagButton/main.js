import { createApp } from 'vue'
import ButtonTag from '@/components/ui/Button/ButtonTag.vue'

function init(element) {
  const globalId = element.getAttribute('data-tag-object-global-id')
  const count = +element.getAttribute('data-inserted-keyword-count')
  const props = {
    globalId,
    count,
    showCount: true
  }
  const app = createApp(ButtonTag, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-tag-default="true"]')) {
    document
      .querySelectorAll('[data-tag-default="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
