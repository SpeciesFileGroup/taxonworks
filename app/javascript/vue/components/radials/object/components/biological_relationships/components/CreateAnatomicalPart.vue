<template>
  <div class="create-anatomical-part">
    <VSwitch
      v-model="mode"
      :options="MODE_OPTIONS"
    />

    <template v-if="mode === MODE_OPTIONS[0]">
      <AnatomicalPartFormFields
        v-model="form"
        :include-is-material="props.includeIsMaterial"
        show-ontology-search
        preparation-type-display="select"
      />
    </template>

    <template v-else>
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
          class="button normal-input tag_button button-data template-pill"
          type="button"
          :title="item.type === 'uri' ? uriTemplateTitle(item) : item.name"
          :class="{ selected: selectedTemplateIndex === index, uri: item.type === 'uri', name: item.type === 'name' }"
          @click="selectTemplate(item, index)"
        >
          <template v-if="item.type === 'name'">
            {{ item.name }}
          </template>
          <template v-else>
            <div>{{ item.uri_label }}</div>
          </template>
        </button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { AnatomicalPart } from '@/routes/endpoints'
import VSwitch from '@/components/ui/VSwitch.vue'
import AnatomicalPartFormFields from '@/components/radials/object/components/origin_relationship/create/anatomical_parts/components/AnatomicalPartFormFields.vue'
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

function uriTemplateTitle(item) {
  return [item.uri_label, item.uri].filter(Boolean).join('\n')
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
  margin: 0;
}

.template-pill.uri {
  border-color: var(--anatomical-part-uri-pill-border);
  background-color: var(--anatomical-part-uri-pill-bg);
  color: var(--anatomical-part-uri-pill-text);
}

.template-pill.name {
  border-color: #58712f;
}

.template-pill.selected {
  box-shadow:
    inset 0 0 0 2px var(--anatomical-part-pill-selected-ring),
    0 0 0 3px var(--anatomical-part-pill-selected-outer);
  filter: brightness(0.9) saturate(1.08);
  font-weight: 700;
}

</style>
