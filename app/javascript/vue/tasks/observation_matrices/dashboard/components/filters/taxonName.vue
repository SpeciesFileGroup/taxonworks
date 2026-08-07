<template>
  <FacetContainer>
    <h3>Taxon name</h3>
    <div class="field">
      <VAutocomplete
        class="fill_width"
        url="/taxon_names/autocomplete"
        param="term"
        display="label"
        label="label_html"
        :clear-after="true"
        placeholder="Search a taxon name"
        :add-params="{
          'type[]': 'Protonym'
        }"
        @select="({ id }) => loadTaxon(id)"
      />
    </div>
    <div
      class="horizontal-left-content gap-small"
      v-if="taxon"
    >
      <span v-html="taxon.object_tag" />
      <VBtn
        color="primary"
        circle
        @click="() => loadTaxon()"
      >
        <VIcon
          name="undo"
          small
        />
      </VBtn>
    </div>
  </FacetContainer>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { TaxonName } from '@/routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import { onMounted } from 'vue'
import { useStore } from 'vuex'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const taxon = defineModel({
  type: Object,
  default: undefined
})

const store = useStore()

onMounted(() => {
  const { taxon_name_id } = URLParamsToJSON(location.href)

  if (taxon_name_id) {
    loadTaxon(taxon_name_id)
  }
})

async function loadTaxon(id) {
  try {
    const data = id ? (await TaxonName.find(id)).body : undefined

    store.commit(MutationNames.SetTaxon, data)
    taxon.value = data
  } catch {}
}
</script>

<style lang="scss" scoped>
.field {
  label {
    display: block;
  }
}
.field-year {
  width: 60px;
}
:deep(.vue-autocomplete-list) {
  min-width: 800px;
}
</style>
