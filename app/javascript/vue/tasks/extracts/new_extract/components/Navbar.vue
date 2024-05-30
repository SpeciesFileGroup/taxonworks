<template>
  <navbar-component v-hotkey="shortcuts">
    <div class="flex-separate middle">
      <div
        class="horizontal-left-content gap-small"
        v-if="extract.id"
      >
        <span v-html="extract.object_tag" />
        <RadialAnnotator :global-id="extract.global_id" />
        <RadialNavigator :global-id="extract.global_id" />
      </div>
      <span v-else> New </span>
      <div class="horizontal-right-content gap-small">
        <tippy
          v-if="unsavedChanges"
          animation="scale"
          placement="bottom"
          size="small"
          inertia
          arrow
          content="You have unsaved changes."
        >
          <span data-icon="warning" />
        </tippy>

        <button
          type="button"
          class="button normal-input button-submit"
          @click="emit('onSave')"
        >
          Save
        </button>
        <button
          type="button"
          class="button normal-input button-default"
          @click="emit('onReset')"
        >
          New
        </button>
      </div>
    </div>
  </navbar-component>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { Tippy } from 'vue-tippy'
import { useStore } from 'vuex'
import { ref, computed } from 'vue'
import NavbarComponent from '@/components/layout/NavBar'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import useHotkey from 'vue3-hotkey'

const emit = defineEmits(['onSave', 'onReset'])

const store = useStore()

const extract = computed(() => store.getters[GetterNames.GetExtract])
const unsavedChanges = computed(
  () =>
    store.getters[GetterNames.GetLastChange] >
    store.getters[GetterNames.GetLastSave]
)

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      emit('onSave')
    }
  },
  {
    keys: [platformKey(), 'n'],
    handler() {
      emit('onReset')
    }
  }
])

useHotkey(shortcuts.value)
</script>
