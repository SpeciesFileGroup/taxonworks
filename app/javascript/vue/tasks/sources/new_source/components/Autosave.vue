<template>
  <div>
    <div class="meter">
      <span class="full_width progress-container">
        <transition
          name="meter-animation"
          @after-enter="save"
        >
          <span
            v-if="triggerAutosave && isReadyToTrigger"
            class="progress"
          />
        </transition>
      </span>
    </div>
  </div>
</template>

<script setup>
import { computed, watch, ref, nextTick } from 'vue'
import { useSourceStore } from '../store'

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  }
})

const store = useSourceStore()

const triggerAutosave = ref(false)

const isReadyToTrigger = computed(
  () => store.isSaveAvailable && store.source.isUnsaved && !props.disabled
)

watch(isReadyToTrigger, restart, { immediate: true })

function save() {
  if (!triggerAutosave.value) return
  store.save()
}

async function restart() {
  triggerAutosave.value = false

  await nextTick()
  triggerAutosave.value = isReadyToTrigger.value
}
</script>

<style lang="scss">
.meter {
  height: 2px;
  position: relative;
  background-color: transparent;
  overflow: hidden;
}

.progress-container {
  display: block;
  height: 100%;
}

.progress {
  display: block;
  height: 100%;
  background-color: var(--color-update);
}

.meter-animation-enter-active {
  animation: progressBar 3s linear;
  animation-fill-mode: both;
}

@keyframes progressBar {
  from {
    width: 0%;
  }

  to {
    width: 100%;
  }
}
</style>
