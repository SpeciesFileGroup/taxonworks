<template>
  <div>
    <h3>Character states</h3>
    <div class="horizontal-left-content align-start gap-small">
      <div class="flex-col middle padding-large-top">
        <ButtonUnify
          :ids="selected"
          :model="CHARACTER_STATE"
        />
      </div>
      <div class="field">
        <label>Label</label><br />
        <input
          class="character-input"
          maxlength="2"
          type="text"
          v-model="characterState.label"
        />
      </div>
      <div class="field">
        <div class="separate-bottom">
          <label>Name</label><br />
          <input
            type="text"
            v-model="characterState.name"
          />
        </div>
        <template v-if="show">
          <div class="separate-bottom">
            <label>Description name</label><br />
            <input
              type="text"
              v-model="characterState.description_name"
            />
          </div>
          <div>
            <label>Key name</label><br />
            <input
              type="text"
              v-model="characterState.key_name"
            />
          </div>
        </template>
      </div>
      <div class="field">
        <br />
        <template v-if="characterState.id">
          <button
            :disabled="!validateFields"
            class="normal-input button button-submit"
            @click="updateCharacter"
            type="button"
          >
            Update
          </button>
          <button
            class="button normal-input button-default margin-small-left"
            @click="resetInputs"
          >
            New
          </button>
        </template>
        <button
          v-else
          @click="createCharacter"
          :disabled="!validateFields"
          class="normal-input button button-submit"
          type="button"
        >
          Add
        </button>
        <a
          class="separate-left cursor-pointer"
          @click="show = !show"
        >
          {{ show ? 'Hide' : 'Show more' }}</a
        >
      </div>
    </div>
    <ul
      v-if="list.length"
      class="table-entrys-list"
    >
      <draggable
        v-model="list"
        item-key="id"
        @end="onSortable"
      >
        <template #item="{ element, index }">
          <li class="flex-separate middle margin-small-bottom">
            <div>
              <label>
                <input
                  type="checkbox"
                  :value="element.id"
                  v-model="selected"
                />
                {{ element.object_tag }}
              </label>
            </div>
            <div class="horizontal-left-content middle gap-xsmall">
              <VBtn
                circle
                color="update"
                @click="editCharacter(index)"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <RadialAnnotator :global-id="element.global_id" />
              <VBtn
                color="destroy"
                circle
                @click="removeCharacter(index)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </li>
        </template>
      </draggable>
    </ul>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import Draggable from 'vuedraggable'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import { CHARACTER_STATE } from '@/constants'
import { computed, ref, watch, onMounted } from 'vue'

const emit = defineEmits(['update:modelValue', 'save'])

const descriptor = defineModel({
  type: Object,
  required: true
})

const list = ref([])
const show = ref(false)
const selected = ref([])
const characterState = ref(newCharacter())

const validateFields = computed(
  () =>
    characterState.value.label &&
    characterState.value.name &&
    descriptor.value.name
)

watch(
  descriptor,
  (newVal, oldVal) => {
    if (
      JSON.stringify(newVal.character_states) !==
      JSON.stringify(oldVal.character_states)
    ) {
      list.value = sortPosition(newVal.character_states)
    }
  },
  { deep: true }
)

onMounted(() => {
  if (descriptor.value.hasOwnProperty('character_states')) {
    list.value = sortPosition(descriptor.value.character_states)
  }
})

function createCharacter() {
  descriptor.value.character_states_attributes = [characterState.value]
  emit('save', descriptor.value)
  resetInputs()
}

function newCharacter() {
  return {
    label: undefined,
    name: undefined,
    description_name: undefined,
    key_name: undefined,
    id: undefined
  }
}

function resetInputs() {
  characterState.value = newCharacter()
}

function removeCharacter(index) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    list[index]._destroy = true
    onSortable()
  }
}

function editCharacter(index) {
  const item = list.value[index]
  Object.assign(characterState.value, {
    ...item
  })
}

function updateCharacter() {
  const index = list.value.findIndex(
    (item) => item.id === characterState.value.id
  )

  if (index > -1) {
    descriptor.value.character_states_attributes = [characterState.value]
    emit('save', descriptor.value)
  }
  resetInputs()
}

function onSortable() {
  updateIndex()
  descriptor.value.character_states_attributes = list.value
  emit('save', descriptor.value)
}

function updateIndex() {
  list.value.forEach((element, index) => {
    element.position = index + 1
  })
}

function sortPosition(list) {
  list.sort((a, b) => {
    if (a.position > b.position) {
      return 1
    }
    return -1
  })
  return list
}
</script>
<style scoped>
.character-input {
  width: 40px !important;
}
</style>
