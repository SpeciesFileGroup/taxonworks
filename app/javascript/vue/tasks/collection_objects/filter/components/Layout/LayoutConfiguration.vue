<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '80vw' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Layout preferences</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <template
          v-for="(propertiesList, key) in properties"
          :key="key"
        >
          <div class="margin-medium-right">
            <h3 class="capitalize">
              <label>
                <input
                  type="checkbox"
                  :checked="
                    propertiesList.length ===
                    currentLayout.properties[key].length
                  "
                  @click="
                    currentLayout.properties[key] =
                      propertiesList.length ===
                      currentLayout.properties[key].length
                        ? []
                        : [...propertiesList]
                  "
                />
                {{ humanize(key) }}
              </label>
            </h3>
            <VueDraggable
              class="no_bullets"
              element="ul"
              v-model="properties[key]"
              :item-key="(item) => item"
              @end="updatePropertiesPositions(key)"
            >
              <template #item="{ element }">
                <li>
                  <label>
                    <input
                      type="checkbox"
                      :value="element"
                      @change="updatePropertiesPositions(key)"
                      v-model="currentLayout.properties[key]"
                    />
                    {{ element }}
                  </label>
                </li>
              </template>
            </VueDraggable>
          </div>
        </template>
        <div v-if="Object.keys(includes).length">
          <h3>Includes</h3>
          <ul class="no_bullets">
            <li
              v-for="(value, key) in includes"
              :key="key"
            >
              <label>
                <input
                  type="checkbox"
                  v-model="currentLayout.includes[key]"
                />
                Data attributes
              </label>
            </li>
          </ul>
        </div>
      </div>
    </template>
  </VModal>
  <select v-model="currentLayout">
    <option
      v-for="(item, key) in layouts"
      :key="key"
      :value="item"
    >
      {{ key }}
    </option>
  </select>

  <VBtn
    class="rounded-tl-none rounded-bl-none"
    medium
    color="primary"
    @click="openLayoutPreferences"
  >
    <VIcon
      name="pencil"
      x-small
    />
  </VBtn>
</template>

<script setup>
import { ref } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VueDraggable from 'vuedraggable'
import VIcon from 'components/ui/VIcon/index.vue'
import { useLayoutConfiguration } from './useLayoutConfiguration'
import { humanize } from 'helpers/strings.js'

const {
  currentLayout,
  layouts,
  properties,
  includes,
  updatePropertiesPositions
} = useLayoutConfiguration()

function openLayoutPreferences() {
  currentLayout.value = layouts.value.Custom
  isModalVisible.value = true
}

const isModalVisible = ref(false)
</script>
