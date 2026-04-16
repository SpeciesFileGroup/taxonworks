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
      <div class="horizontal-left-content align-start gap-medium">
        <VueDraggable
          class="horizontal-left-content align-start gap-medium"
          element="div"
          group="lists"
          :list="Object.entries(props.layouts.Custom.properties)"
          :item-key="([key]) => key"
          @end="sortObjects"
        >
          <template #item="{ element: [key] }">
            <div>
              <h3
                class="capitalize cursor-grab horizontal-left-content gap-small"
              >
                <label class="cursor-grab">
                  <input
                    type="checkbox"
                    :checked="
                      isTheSameValue({
                        properties: properties[key],
                        layout: currentLayout.properties[key]
                      })
                    "
                    @click="
                      () => {
                        currentLayout.properties[key] = setProperties({
                          properties: properties[key],
                          layout: currentLayout.properties[key]
                        })
                        emit('update')
                      }
                    "
                  />
                  {{ humanize(key) }}
                </label>
                <IconRightLeft class="w-4" />
              </h3>
              <VueDraggable
                v-if="Array.isArray(properties[key])"
                class="no_bullets"
                element="ul"
                :group="`items-${key}`"
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
                        @change="
                          () => {
                            currentLayout.properties[key] = sortArrayByArray(
                              currentLayout.properties[key],
                              properties[key],
                              true
                            )
                            emit('update', key)
                          }
                        "
                      />
                      {{ element }}
                    </label>
                  </li>
                </template>
              </VueDraggable>
            </div>
          </template>
        </VueDraggable>
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
      v-help="
        'Customize layout: Properties can be toggled on or off by clicking the checkboxes. You can also reorder them by dragging. Also, columns can be rearranged by dragging them left or right.'
      "
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
import { ref, watch } from 'vue'
import { humanize } from '@/helpers/strings.js'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VueDraggable from 'vuedraggable'
import VIcon from '@/components/ui/VIcon/index.vue'
import { sortArrayByArray } from '@/helpers'
import IconRightLeft from '@/components/Icon/IconRightLeft.vue'
import { vHelp } from '@/directives'

const props = defineProps({
  layouts: {
    type: Object,
    default: () => ({})
  }
})

const currentLayout = defineModel()
const includes = defineModel('includes')
const properties = defineModel('properties')

const emit = defineEmits(['update', 'select', 'sort', 'reset', 'sort:column'])

const isModalVisible = ref(false)

function openLayoutPreferences() {
  currentLayout.value = props.layouts.Custom
  isModalVisible.value = true
}

function isTheSameValue({ properties, layout }) {
  return Array.isArray(properties)
    ? properties.length === layout.length
    : properties.show === layout.show
}

function setProperties({ properties, layout }) {
  const isTheSame = isTheSameValue({ properties, layout })

  if (Array.isArray(properties)) {
    return isTheSame ? [] : [...properties]
  } else {
    return {
      show: !layout.show
    }
  }
}

function sortObjects(e) {
  const newArr = Object.entries(currentLayout.value.properties)
  const { newIndex, oldIndex } = e
  const [movedElement] = newArr.splice(oldIndex, 1)

  newArr.splice(newIndex, 0, movedElement)
  currentLayout.value.properties = Object.fromEntries(newArr)

  emit('sort:column')
}

watch(
  () => props.layouts.Custom,
  () => {
    currentLayout.value = props.layouts.Custom
  },
  { deep: true }
)
</script>
