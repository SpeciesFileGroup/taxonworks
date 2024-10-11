<template>
  <FacetContainer>
    <h3>Gazetteer (spatial)</h3>
    <div class="field">
      <VAutocomplete
        :input-id="inputId"
        url="/gazetteers/autocomplete"
        label="label_html"
        clear-after
        placeholder="Search a gazetteer"
        param="term"
        @get-item="({ id }) => addGazetteer(id)"
      />
    </div>

    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(gz, index) in gazetteers"
          :key="gz.id"
        >
          <span>
            {{ gz.name }}
          </span>
          <VBtn
            circle
            color="primary"
            @click="removeGz(index)"
          >
            <VIcon
              x-small
              name="trash"
            />
          </VBtn>
        </li>
      </ul>
    </div>
    <RadialFilterAttribute
      :parameters="{ gazetteer_id: geographic.gazetteer_id }"
    />
  </FacetContainer>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import RadialFilterAttribute from '@/components/radials/linker/RadialFilterAttribute.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { Gazetteer } from '@/routes/endpoints'
import { ref, watch, onBeforeMount } from 'vue'

// Currently unused since Spatial is the only one that applies to gazetteer
//const GAZETTEER_OPTIONS = {
// Spatial: true,
// Exact: undefined // exact id match, unused since no model belongs_to a GZ
//}

const props = defineProps({
  inputId: {
    type: String,
    default: undefined
  }
})

const geographic = defineModel()
const gazetteers = ref([])

watch(geographic, (newVal) => {
  if (!newVal?.length) {
    gazetteers.value = []
  }
})

function removeGz(index) {
  gazetteers.value.splice(index, 1)
}

function addGazetteer(id) {
  Gazetteer.find(id).then((response) => {
    gazetteers.value.push(response.body)
  })
}

watch(
  () => geographic.value.gazetteer_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      gazetteers.value = []
    }
  },
  { deep: true }
)

watch(
  gazetteers,
  () => {
    geographic.value.gazetteer_id = gazetteers.value.map((item) => item.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  if (geographic.value.gazetteer_id) {
    [geographic.value.gazetteer_id].flat().forEach((id) => {
      addGazetteer(id)
    })
  }
})
</script>

<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
