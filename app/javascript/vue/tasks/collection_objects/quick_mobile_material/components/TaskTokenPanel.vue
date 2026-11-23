<template>
  <div class="flex-col gap-small">
    <div class="horizontal-right-content middle gap-small">
      <span
        class="feedback feedback-thin"
        :class="statusClass"
      >
        {{ store.status }}
      </span>
      <VBtn
        color="primary"
        medium
        title="Refresh the status and the table"
        @click="store.refresh()"
      >
        Refresh
      </VBtn>
      <VBtn
        color="primary"
        medium
        :disabled="!store.composition"
        @click="store.issueTaskToken()"
      >
        New session
      </VBtn>
      <VBtn
        color="destroy"
        medium
        :disabled="!store.taskToken"
        @click="store.invalidateTaskToken()"
      >
        Invalidate
      </VBtn>
      <RecentButton @select="({ id }) => emit('select', { id })" />
    </div>

    <div
      v-if="store.composition"
      class="horizontal-right-content"
    >
      <div
        v-if="store.isQrCodeLive"
        class="flex-col middle"
      >
        <QrCode
          :svg="store.qrCode.svg"
          label="Scan with the mobile app"
        />
        <span>Expires in {{ formatSeconds(store.secondsLeft) }}</span>
      </div>
      <div
        v-else
        class="flex-col middle gap-small"
      >
        <span v-if="store.status === STATUS.Connected">
          Session ends in {{ formatSeconds(store.secondsLeft) }}
        </span>
        <VBtn
          color="primary"
          medium
          @click="newQrCode"
        >
          Show a new QR code
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, watch } from 'vue'
import { useInterval } from '@/composables'
import { STATUS } from '../constants'
import useStore from '../store/store'
import QrCode from '@/components/ui/QrCode/QrCode.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RecentButton from './RecentButton.vue'

const emit = defineEmits(['select'])

const store = useStore()

useInterval(() => store.tick(), 1000)

const statusClass = computed(() => ({
  'feedback-success': store.status === STATUS.Connected,
  'feedback-info': store.status === STATUS.Waiting,
  'feedback-warning': [STATUS.Expired, STATUS.Invalidated].includes(store.status)
}))

// When the QR code runs out check once whether it was scanned (not polling,
// and never issue a new token automatically)
watch(
  () => store.isQrCodeLive,
  (live, wasLive) => {
    if (wasLive && !live) store.loadTaskTokenStatus().catch(() => {})
  }
)

function newQrCode() {
  if (
    store.status === STATUS.Connected &&
    !window.confirm(
      'A mobile app is connected. A new QR code ends its session. Continue?'
    )
  ) {
    return
  }

  store.issueTaskToken()
}

function formatSeconds(total) {
  const h = Math.floor(total / 3600)
  const m = Math.floor((total % 3600) / 60)
  const s = String(total % 60).padStart(2, '0')

  return h ? `${h}:${String(m).padStart(2, '0')}:${s}` : `${m}:${s}`
}
</script>
