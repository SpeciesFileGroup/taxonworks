<template>
  <div class="create-anatomical-part">
    <VSwitch
      v-model="mode"
      :options="MODE_OPTIONS"
    />

    <div
      v-if="props.includeIsMaterial"
      class="margin-small-top"
    >
      <label>
        <input
          type="checkbox"
          v-model="form.is_material"
        />
        Is material
      </label>
    </div>

    <template v-if="mode === MODE_OPTIONS[0]">
      <fieldset class="margin-small-top">
        <legend>Name or URI</legend>

        <div class="margin-small-bottom">
          <input
            v-model="form.name"
            class="normal-input"
            placeholder="Name"
            type="text"
          />
        </div>

        <div class="margin-small-bottom">or</div>

        <div class="horizontal-left-content gap-small">
          <input
            v-model="form.uri_label"
            class="normal-input"
            placeholder="URI label"
            type="text"
          />
          <input
            v-model="form.uri"
            class="normal-input"
            placeholder="URI"
            type="text"
          />
        </div>
      </fieldset>

      <div class="margin-small-top">
        <label>
          Preparation type
          <select
            v-model="form.preparation_type_id"
            class="normal-input"
          >
            <option :value="null">None</option>
            <option
              v-for="type in preparationTypes"
              :key="type.id"
              :value="type.id"
            >
              {{ type.name }}
            </option>
          </select>
        </label>
      </div>
    </template>

    <template v-else>
      <div
        v-if="props.requiresIsMaterialBeforeTemplate && form.is_material === null"
        class="margin-small-top"
      >
        Choose <i>Is material</i> before selecting a template.
      </div>

      <div
        v-else
        class="template-list margin-small-top"
      >
        <button
          v-for="(item, index) in templates"
          :key="index"
          class="button button-default template-pill"
          type="button"
          :class="{ selected: selectedTemplateIndex === index, uri: item.type === 'uri', name: item.type === 'name' }"
          @click="selectTemplate(item, index)"
        >
          <template v-if="item.type === 'name'">
            {{ item.name }}
          </template>
          <template v-else>
            <div>{{ item.uri_label }}</div>
            <div class="uri-label">{{ item.uri }}</div>
          </template>
        </button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { AnatomicalPart, PreparationType } from '@/routes/endpoints'
import VSwitch from '@/components/ui/VSwitch.vue'
import { computed, onMounted, ref, watch } from 'vue'

const MODE_OPTIONS = ['Create new part', 'Create from existing part']

const props = defineProps({
  includeIsMaterial: {
    type: Boolean,
    default: false
  },

  requiresIsMaterialBeforeTemplate: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['change'])

const mode = ref(MODE_OPTIONS[1])
const templates = ref([])
const preparationTypes = ref([])
const selectedTemplateIndex = ref(null)

const form = ref({
  name: undefined,
  uri: undefined,
  uri_label: undefined,
  is_material: props.includeIsMaterial ? null : undefined,
  preparation_type_id: null
})

const hasName = computed(() => Boolean(form.value.name?.trim()))
const hasUri = computed(() => Boolean(form.value.uri?.trim()))
const hasUriLabel = computed(() => Boolean(form.value.uri_label?.trim()))

const validNameOrUri = computed(() => {
  const hasUriPair = hasUri.value && hasUriLabel.value
  return (hasName.value && !hasUriPair) || (!hasName.value && hasUriPair)
})

const validIsMaterial = computed(() => {
  return !props.includeIsMaterial || form.value.is_material !== null
})

const validTemplateMode = computed(() => {
  const hasTemplate = selectedTemplateIndex.value !== null
  if (!hasTemplate) {
    return false
  }

  return !props.requiresIsMaterialBeforeTemplate || form.value.is_material !== null
})

const valid = computed(() => {
  if (mode.value === MODE_OPTIONS[0]) {
    return validNameOrUri.value && validIsMaterial.value
  }

  return validTemplateMode.value
})

function selectTemplate(item, index) {
  selectedTemplateIndex.value = index

  if (item.type === 'name') {
    form.value.name = item.name
    form.value.uri = undefined
    form.value.uri_label = undefined
  } else {
    form.value.name = undefined
    form.value.uri = item.uri
    form.value.uri_label = item.uri_label
  }
}

function payload() {
  const base = {
    name: hasName.value ? form.value.name.trim() : undefined,
    uri: hasUri.value ? form.value.uri.trim() : undefined,
    uri_label: hasUriLabel.value ? form.value.uri_label.trim() : undefined,
    is_material: props.includeIsMaterial ? form.value.is_material : undefined
  }

  if (mode.value === MODE_OPTIONS[0]) {
    base.preparation_type_id = form.value.preparation_type_id || undefined
  }

  return base
}

watch(
  [mode, form],
  () => {
    if (mode.value === MODE_OPTIONS[0]) {
      selectedTemplateIndex.value = null
    }

    emit('change', {
      valid: valid.value,
      payload: payload()
    })
  },
  { deep: true, immediate: true }
)

onMounted(() => {
  AnatomicalPart.templates()
    .then(({ body }) => {
      templates.value = body
    })
    .catch(() => {})

  PreparationType.all()
    .then(({ body }) => {
      preparationTypes.value = body
    })
    .catch(() => {})
})
</script>

<style scoped>
.template-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  max-height: 200px;
  overflow-y: auto;
}

.template-pill {
  border: 1px solid #666;
  background: #f7f7f7;
}

.template-pill.uri {
  border-color: #2b69b1;
}

.template-pill.name {
  border-color: #58712f;
}

.template-pill.selected {
  box-shadow: inset 0 0 0 2px #000;
}

.uri-label {
  font-size: 0.9em;
}
</style>
