<template>
  <div class="panel content">
    <div class="flex-separate middle gap-medium">
      <span
        class="word_break ellipsis"
        :title="queryString"
      >
        JSON Request URL: {{ queryString }}
      </span>
      <div class="horizontal-right-content middle gap-small">
        <div class="square-brackets">
          <ul class="context-menu no_bullets">
            <li class="flex-row gap-small middle">
              Internal
              <ButtonClipboard
                title="For internal use (Requires project member)"
                :text="queryString"
              />
            </li>

            <li
              v-if="isFilterUrl && projectToken && props.url"
              class="flex-row gap-small middle"
            >
              API
              <ButtonClipboard
                title="Public API URL (includes project token)"
                :text="apiString"
              />
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { getCurrentProjectToken } from '@/helpers'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'

const props = defineProps({
  url: {
    type: String,
    default: ''
  }
})

const projectToken = getCurrentProjectToken()

const isTooLong = computed(() => props.url.length > 2048)

const queryString = computed(() => {
  return isTooLong.value ? 'URL too long for GET request' : props.url
})

const apiString = computed(() => {
  return isTooLong.value
    ? 'URL too long for GET request'
    : buildApiUrl(props.url, projectToken)
})

const isFilterUrl = computed(() => props.url.includes('/filter.json'))

function buildApiUrl(originalUrl, projectToken) {
  try {
    const url = new URL(originalUrl)

    if (!url.pathname.startsWith('/api/v1')) {
      url.pathname = '/api/v1' + url.pathname
    }

    url.pathname = url.pathname.replace('/filter.json', '')
    url.searchParams.set('project_token', projectToken)

    return url.toString()
  } catch {
    return 'Invalid URL'
  }
}
</script>
