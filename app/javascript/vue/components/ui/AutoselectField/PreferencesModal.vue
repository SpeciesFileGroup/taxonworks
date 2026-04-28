<!-- PreferencesModal.vue
  Generic preferences modal opened by the !p operator in AutoselectField.

  Shows:
  - A checkbox row per level: users can hide/show individual levels in the fuse bar.
  - A "Show info" toggle: globally enables or disables the info column per instance.
  - An optional model-specific options section rendered via the optionsComponent prop.

  Emits:
    save(prefs)   — user clicked Save; prefs is the full updated preferences object
    cancel        — user backed out without saving
-->
<template>
  <Modal
    :container-style="{ maxWidth: '420px', width: '90vw' }"
    @close="emit('cancel')"
  >
    <template #header>
      <span>Preferences</span>
    </template>

    <template #body>
      <div class="prefs-modal__body">

        <!-- Level visibility -->
        <section class="prefs-modal__section">
          <h4 class="prefs-modal__section-title">Visible levels</h4>
          <ul class="prefs-modal__levels">
            <li
              v-for="level in levels"
              :key="level.key"
              class="prefs-modal__level-row"
            >
              <label class="prefs-modal__level-label">
                <input
                  type="checkbox"
                  :checked="!draft.levels[level.key]?.hide"
                  @change="toggleLevel(level.key, $event.target.checked)"
                />
                <span>{{ level.label }}</span>
                <span
                  v-if="level.external"
                  class="prefs-modal__level-badge"
                >external</span>
              </label>
            </li>
          </ul>
        </section>

        <!-- Display options -->
        <section class="prefs-modal__section">
          <h4 class="prefs-modal__section-title">Display</h4>
          <label class="prefs-modal__level-label">
            <input
              type="checkbox"
              :checked="draft.show_info"
              @change="draft.show_info = $event.target.checked"
            />
            <span>Show info</span>
          </label>
        </section>

        <!-- Model-specific options section -->
        <section
          v-if="optionsComponent"
          class="prefs-modal__section"
        >
          <h4 class="prefs-modal__section-title">Options</h4>
          <component
            :is="optionsComponent"
            :levels="levels"
            :model-value="draft.levelOptions"
            @update:model-value="draft.levelOptions = $event"
          />
        </section>

      </div>
    </template>

    <template #footer>
      <div class="prefs-modal__footer">
        <button
          class="button button-submit"
          @click="doSave"
        >
          Save
        </button>
        <button
          class="button circle-button btn-undo button-default"
          title="Cancel"
          @click="emit('cancel')"
        >
          &#8617;
        </button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
import { reactive } from 'vue'
import Modal from '@/components/ui/Modal.vue'

const props = defineProps({
  // Array of level metadata objects from the autoselect config
  levels: { type: Array, required: true },

  // Current saved preferences { levels: { key: { hide, options } }, show_info: Boolean }
  currentPrefs: { type: Object, default: () => ({ levels: {} }) },

  // Optional Vue component for model-specific options.
  // Receives props: levels (Array), modelValue (Object of level-keyed options)
  // Emits: update:modelValue
  optionsComponent: { type: Object, default: null }
})

const emit = defineEmits(['save', 'cancel'])

// Deep-copy current prefs into a draft that we can mutate freely
const draft = reactive({
  levels: Object.fromEntries(
    Object.entries(props.currentPrefs.levels || {}).map(([k, v]) => [k, { ...v, options: { ...(v.options || {}) } }])
  ),
  // levelOptions is a flat { level_key: { ...options } } map used by optionsComponent
  levelOptions: Object.fromEntries(
    Object.entries(props.currentPrefs.levels || {}).map(([k, v]) => [k, { ...(v.options || {}) }])
  ),
  show_info: props.currentPrefs.show_info !== false
})

function toggleLevel(key, checked) {
  draft.levels[key] ??= {}
  draft.levels[key].hide = !checked
}

function doSave() {
  // Merge levelOptions back into draft.levels
  for (const [key, opts] of Object.entries(draft.levelOptions)) {
    draft.levels[key] ??= {}
    draft.levels[key].options = { ...opts }
  }

  emit('save', { levels: { ...draft.levels }, show_info: draft.show_info })
}
</script>

<style scoped>
.prefs-modal__body {
  display: flex;
  flex-direction: column;
  gap: 16px;
  font-size: 12px;
}

.prefs-modal__section-title {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-color-muted, #666);
  margin: 0 0 6px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.prefs-modal__levels {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.prefs-modal__level-row {
  display: flex;
  align-items: center;
}

.prefs-modal__level-label {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  user-select: none;
}

.prefs-modal__level-badge {
  font-size: 10px;
  color: var(--text-color-muted, #888);
  background: var(--border-color, #e0e0e0);
  border-radius: 3px;
  padding: 1px 5px;
}

.prefs-modal__footer {
  display: flex;
  align-items: center;
  gap: 8px;
}


</style>
