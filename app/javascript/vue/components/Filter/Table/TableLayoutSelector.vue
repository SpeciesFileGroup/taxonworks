<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '80vw' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Layout preferences</h3>
      <VBtn
        color="submit"
        medium
        @click="emit('reset')"
      >
        Reset
      </VBtn>
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
                    () => {
                      currentLayout.properties[key] =
                        propertiesList.length ===
                        currentLayout.properties[key].length
                          ? []
                          : [...propertiesList]
                      emit('update')
                    }
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
              @end="
                () => {
                  emit('sort', key)
                  emit('update')
                }
              "
            >
              <template #item="{ element }">
                <li>
                  <label class="cursor-grab">
                    <input
                      type="checkbox"
                      :value="element"
                      v-model="currentLayout.properties[key]"
                      @change="() => emit('update', key)"
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
                  @change="() => emit('update', key)"
                />
                {{ humanize(key) }}
              </label>
            </li>
          </ul>
        </div>
      </div>
    </template>
    <template #footer>
      <VBtn
        color="submit"
        medium
        @click="emit('reset')"
      >
        Reset
      </VBtn>
    </template>
  </VModal>
  <div class="horizontal-left-content middle">
    <select
      v-model="currentLayout"
      @change="emit('select')"
    >
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
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { humanize } from '@/helpers/strings.js'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VueDraggable from 'vuedraggable'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  layouts: {
    type: Object,
    default: () => ({})
  }
})

const currentLayout = defineModel()
const includes = defineModel('includes')
const properties = defineModel('properties')

const emit = defineEmits(['update', 'select', 'sort', 'reset'])

const isModalVisible = ref(false)

function openLayoutPreferences() {
  currentLayout.value = props.layouts.Custom
  isModalVisible.value = true
}
</script>
