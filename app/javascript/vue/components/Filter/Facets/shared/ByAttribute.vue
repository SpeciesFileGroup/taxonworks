<template>
  <div class="horizontal-left-content align-start">
    <div class="field separate-right full_width">
      <label>Field</label>
      <br />
      <select
        class="normal-input full_width"
        v-model="selectedField"
      >
        <template
          v-for="name in fieldNames"
          :key="name"
        >
          <option
            v-if="!selectedFields.find((item) => item.param === name)"
            :value="{name, type: fields[name]}"
          >
            {{ name }}
          </option>
        </template>
      </select>
    </div>
  </div>
  <AttributeForm
    v-if="selectedField"
    class="horizontal-left-content"
    :field="selectedField"
    @add="addField"
  />

  <div v-if="selectedFields.length">
    <div class="facet_grid">
      <div class="gh">Field</div>
      <div class="gh">Value</div>
      <div class="gh">Exact</div>
      <div class="gh"></div>
      <template
        v-for="(field, index) in selectedFields"
        :key="field.param"
      >
        <div class="gd">{{ field.param }}</div>
        <div class="gd">{{ field.value }}</div>
        <div class="gd gd_input">
          <template v-if="allowExactForField(field)">
            <input
              v-model="field.exact"
              type="checkbox"
            />
          </template>
          <template v-else>
            <template v-if="field.any">Any</template>
            <template v-else-if="!field.value">Empty</template>
            <template v-else>Substring</template>
          </template>
        </div>
        <div class="gd">
          <span class="button circle-button btn-delete button-default"
            @click="removeField(index)"
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed, onBeforeMount } from 'vue'
import ajaxCall from '@/helpers/ajaxCall'
import AttributeForm from '@/components/Filter/Facets/CollectingEvent/FacetCollectingEvent/AttributeForm.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  controller: {
    type: String,
    required: true
  },

  exclude: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const fields = ref({}) // hash of field_name => field_type
const fieldNames = ref([])
// selectedFields are {param: string, type:, value:, any: bool, exact: bool}
// where type is the class type of the parameter named param, 'any' means filter
// on any non-null value, and 'exact' means the user checked a box to say
// 'require an exact match on value'.
const selectedFields = ref([])
const selectedField = ref(undefined)

watch(
  selectedFields,
  (newVal) => {
    const attributes = {}

    params.value.any_value_attribute = newVal
      .filter((item) => item.any)
      .map((item) => item.param)

    params.value.no_value_attribute = newVal
      .filter((item) => !item.value && !item.any)
      .map((item) => item.param)

    params.value.wildcard_attribute = newVal
      .filter((item) => fieldIsWildcard(item))
      .map((item) => item.param)

    fieldNames.value.forEach((name) => {
      attributes[name] = undefined
    })

    newVal.forEach(({ param, value }) => {
      attributes[param] = value
    })

    Object.assign(params.value, attributes)
  },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal) => {
    const parameters = Object.keys(newVal)
    const isAttributeSetted = fieldNames.value.some((name) =>
      parameters.includes(name)
    )

    // TODO: why wildcard check?
    if (!parameters.includes('wildcard_attribute') && !isAttributeSetted) {
      selectedFields.value = []
    }
  }
)

onBeforeMount(() => {
  ajaxCall('get', `/${props.controller}/attributes`).then((response) => {
    const includedAttributes = response.body.filter(
      ({ name }) => !props.exclude.includes(name)
    )

    fields.value = {}
    includedAttributes.forEach(({ name, type }) => {
      fields.value[name] = type
      const value = params.value[name]
      const noValue = params.value.no_value_attribute?.includes(name)
      const any = params.value.any_value_attribute?.includes(name)

      if (value === undefined && !noValue && !any) {
        return
      }

      const exact = !!value && !any &&
        !params.value.wildcard_attribute?.includes(name)

      selectedFields.value.push(
        {
          param: name,
          value,
          type,
          any,
          exact
        }
      )
    })

    fieldNames.value = Object.keys(fields.value).sort()
  })
})

const addField = (field) => {
  selectedFields.value.push({...field, exact: false})
  selectedField.value = undefined
}

const removeField = (index) => {
  selectedFields.value.splice(index, 1)
}

const fieldIsWildcard = (field) => {
  // i.e. not none, not any, not checkboxed as Exact by user (could mean a
  // checkbox was never offered for that field, cf. allowExactForField)
  return !!field.value && !field.any && !field.exact
}

const allowExactForField = (field) => {
  const type = field.type
  return !!field.value && !field.any && // i.e. not none, not any
    (type === 'string' || type === 'text' ||
     type === 'integer' || type === 'decimal')
}
</script>

<style scoped>
.facet_grid {
  display: grid;
  grid-template-columns: auto auto fit-content(6em) fit-content(24px);
	box-shadow: 0 0 2px 0 #e5e5e5;
	border-radius: 2px;
	background-color: #fff;
}

.gh {
  border-bottom: 2px solid #98b798;
  text-align: left;
  height: 40px;
  line-height: 40px;
  font-size: 12px;
  padding-left: 1em;
  padding-right: 1em;
}

.gh:hover {
  background: #e3e8e3;
}

.gd {
  display: flex;
  align-items: center;
  word-break: break-all;
  padding-left: .5em;
  padding-right: .5em;
  min-height: 40px;
}

.gd_input {
  justify-content: center;
}
</style>
