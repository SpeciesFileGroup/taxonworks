<template>
  <div class="field">
    <SmartSelector
      model="taxon_names"
      :filter-ids="[...objectIds, ...subjectIds, ...bothIds]"
      @selected="addTaxonName"
    />
    <template v-if="taxonNames.length">
      <table
        v-if="relation"
        class="vue-table"
      >
        <thead>
          <tr>
            <th>Taxon name</th>
            <th />
            <th />
          </tr>
        </thead>
        <transition-group
          name="list-complete"
          tag="tbody"
        >
          <template
            v-for="(item, index) in taxonNames"
            :key="index"
          >
            <row-item
              class="list-complete-item"
              :item="item"
              label="object_tag"
              :options="{
                subject: true,
                object: false,
                both: undefined
              }"
              v-model="item.isSubject"
              @remove="removeTaxonName(item)"
            />
          </template>
        </transition-group>
      </table>
      <DisplayList
        v-else
        :list="taxonNames"
        label="object_tag"
        :delete-warning="false"
        @delete="removeTaxonName"
      />
    </template>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import RowItem from 'components/Filter/Facets/shared/RowItem.vue'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'
import { ref, computed, onBeforeMount, watch } from 'vue'
import { removeFromArray } from 'helpers/arrays'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  relation: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const taxonNames = ref([])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const objectIds = computed({
  get: () => params.value.object_taxon_name_id || [],
  set: value => {
    params.value.object_taxon_name_id = value
  }
})

const subjectIds = computed({
  get: () => params.value.subject_taxon_name_id || [],
  set: value => {
    params.value.subject_taxon_name_id = value
  }
})

const bothIds = computed({
  get: () => params.value.taxon_name_id || [],
  set: value => {
    params.value.taxon_name_id = value
  }
})

watch(
  [objectIds, subjectIds],
  () => {
    if (
      !objectIds.value?.length &&
      !bothIds.value?.length &&
      !subjectIds.value?.length &&
      taxonNames.value.length
    ) {
      taxonNames.value = []
    }
  }
)

watch(
  taxonNames,
  newVal => {
    bothIds.value = newVal.filter(item => item.isSubject === undefined).map(item => item.id)
    objectIds.value = newVal.filter(item => item.isSubject === false).map(item => item.id)
    subjectIds.value = newVal.filter(item => item.isSubject).map(item => item.id)
  },
  { deep: true }
)

function addTaxonName (item) {
  taxonNames.value.push({
    ...item,
    isSubject: undefined
  })
}

function removeTaxonName (taxonName) {
  removeFromArray(taxonNames.value, taxonName)
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  urlParams.subject_taxon_name_id?.forEach(id => {
    TaxonName.find(id).then(({ body }) => {
      addTaxonName({ ...body, isSubject: true })
    })
  })

  urlParams.object_taxon_name_id?.forEach(id => {
    TaxonName.find(id).then(({ body }) => {
      addTaxonName({ ...body, isSubject: false })
    })
  })

  urlParams.taxon_name_id?.forEach(id => {
    TaxonName.find(id).then(({ body }) => {
      addTaxonName({ ...body, isSubject: undefined })
    })
  })
})

</script>
