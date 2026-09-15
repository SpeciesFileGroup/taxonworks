<template>
  <VModal
    v-if="isVisible"
    :container-style="{ maxWidth: '480px' }"
    @close="isDismissed = true"
  >
    <template #header>
      <h3>Session expired</h3>
    </template>
    <template #body>
      <p>{{ message }}</p>
      <p>
        Requests from this page will keep failing until it is reloaded. Anything
        you have typed and not saved will be lost.
      </p>
    </template>
    <template #footer>
      <VBtn
        color="primary"
        medium
        @click="reload"
      >
        Reload page
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { SESSION_EXPIRED_REASON, sessionStatus } from '@/utils/SessionStatus'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'

defineOptions({
  name: 'KeepAlive'
})

const MESSAGES = {
  [SESSION_EXPIRED_REASON.ProjectLost]:
    'Your session expired after being idle for too long.',
  [SESSION_EXPIRED_REASON.SignedOut]:
    'You are no longer signed in. You may have signed out in another tab.'
}

const isDismissed = ref(false)

const isVisible = computed(() => sessionStatus.isExpired && !isDismissed.value)

const message = computed(() => MESSAGES[sessionStatus.reason] || '')

watch(
  () => sessionStatus.isExpired,
  (isExpired) => {
    if (isExpired) isDismissed.value = false
  }
)

function reload() {
  window.location.reload()
}
</script>
