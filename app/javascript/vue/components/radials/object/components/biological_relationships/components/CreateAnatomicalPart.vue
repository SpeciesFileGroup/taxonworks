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
        v-if="templatesLoaded && templates.length === 0"
        class="template-empty-notice margin-small-top"
      >
        No existing parts in this project yet.
      </div>

      <div
        v-else
        class="template-list margin-small-top"
      >
        <VBtn
          v-for="(item, index) in templates"
          :key="index"
          medium
          :color="selectedTemplateIndex === index ? 'default' : 'primary'"
          class="template-pill btn-pill-left"
          :title="item.type === 'uri' ? uriTemplateTitle(item) : item.name"
          :class="{
            selected: selectedTemplateIndex === index,
            uri: item.type === 'uri' && selectedTemplateIndex !== index
          }"
          @click="selectTemplate(item, index)"
        >
          <template v-if="item.type === 'name'">
            {{ item.name }}
          </template>
          <template v-else>
            <div>{{ item.uri_label }}</div>
          </template>
        </VBtn>
      </div>
    </template>
  </div>
</template>

<script setup>
import { AnatomicalPart } from '@/routes/endpoints'
import VSwitch from '@/components/ui/VSwitch.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import AnatomicalPartFormFields from '@/components/radials/object/components/origin_relationship/create/anatomical_parts/components/AnatomicalPartFormFields.vue'
import { computed, onMounted, ref, watch } from 'vue'

const MODE_OPTIONS = ['Create new part', 'Create from existing part']

const props = defineProps({
  includeIsMaterial: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['change'])

const mode = ref(MODE_OPTIONS[1])
const templates = ref([])
const templatesLoaded = ref(false)
const selectedTemplateIndex = ref(null)

const form = ref({
  name: undefined,
  uri: undefined,
  uri_label: undefined,
  is_material: props.includeIsMaterial ? false : undefined,
  preparation_type_id: null
})

const hasName = computed(() => Boolean(form.value.name?.trim()))
const hasUri = computed(() => Boolean(form.value.uri?.trim()))
const hasUriLabel = computed(() => Boolean(form.value.uri_label?.trim()))

const validNameOrUri = computed(() => {
  const hasUriPair = hasUri.value && hasUriLabel.value
  return (hasName.value && !hasUriPair) || (!hasName.value && hasUriPair)
})

const validTemplateMode = computed(() => selectedTemplateIndex.value !== null)

const valid = computed(() => {
  if (mode.value === MODE_OPTIONS[0]) {
    return validNameOrUri.value
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
      if (body.length === 0) {
        mode.value = MODE_OPTIONS[0]
      }
    })
    .catch(() => {})
    .finally(() => {
      templatesLoaded.value = true
    })
})
</script>

<style scoped>
.template-empty-notice {
  color: var(--text-muted-color);
  font-size: 0.9rem;
}

.template-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  max-height: 200px;
  overflow-y: auto;
}

.template-pill {
  min-width: 60px !important;
}

.template-pill.uri {
  border-color: var(--anatomical-part-uri-pill-border);
  background-color: var(--anatomical-part-uri-pill-bg);
  color: var(--anatomical-part-uri-pill-text);
}

.template-pill.selected {
  border-color: transparent;
  box-shadow: none;
  filter: none;
}

</style>
