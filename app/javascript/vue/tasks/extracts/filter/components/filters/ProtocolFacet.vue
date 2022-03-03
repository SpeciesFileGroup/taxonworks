<template>
  <div>
    <h3>Protocols</h3>
    <fieldset>
      <legend>Protocol</legend>
      <smart-selector
        model="protocols"
        klass="Tags"
        pin-section="Protocols"
        pin-type="Protocol"
        @selected="addToArray(protocols, $event)"/>
    </fieldset>
    <table
      v-if="protocols.length"
      class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th />
          <th />
        </tr>
      </thead>
      <transition-group
        class="table-entrys-list"
        name="list-complete"
        tag="tbody">
        <template
          v-for="(item, index) in protocols"
          :key="index"
        >
          <row-item
            class="list-complete-item"
            :item="item"
            label="object_tag"
            :options="{
              AND: true,
              OR: false
            }"
            v-model="protocols[index].and"
            @remove="removeFromArray(protocols, item)"
          />
        </template>
      </transition-group>
    </table>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import { computed, ref, watch } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Protocol } from 'routes/endpoints'
import { addToArray, removeFromArray } from 'helpers/arrays'
import RowItem from 'tasks/sources/filter/components/filters//shared/RowItem'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const protocols = ref([])

watch(
  () => props.modelValue,
  newVal => {
    if (
      !newVal.protocol_id_and.length &&
      !newVal.protocol_id_or.length &&
      protocols.value.length) {
      protocols.value = []
    }
  }
)

watch(
  protocols,
  () => {
    params.value = {
      protocol_id_and: protocols.value.filter(protocol => protocol.and).map(protocol => protocol.id),
      protocol_id_or: protocols.value.filter(protocol => !protocol.and).map(protocol => protocol.id)
    }
  },
  { deep: true }
)

const urlParams = URLParamsToJSON(location.href)
const {
  protocol_id_and = [],
  protocol_id_or = []
} = urlParams

Promise
  .all(protocol_id_and.map(id => Protocol.find(id)))
  .then(responses => {
    responses.forEach(({ body }) => {
      addToArray(protocols.value, { ...body, and: true })
    })
  })

Promise
  .all(protocol_id_or.map(id => Protocol.find(id)))
  .then(responses => {
    responses.forEach(({ body }) => {
      addToArray(protocols.value, { ...body, and: false })
    })
  })

</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
