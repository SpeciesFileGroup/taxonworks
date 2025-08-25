<template>
  <li>
    <VBtn
      v-if="!taxon.leaf"
      circle
      small
      color="primary"
      :disabled="isLoading"
      @click="toggle"
    >
      <span v-if="taxon.isLoaded && taxon.isExpanded">-</span>
      <span v-else>+</span>
    </VBtn>
    <span
      v-if="currentId === taxon.id"
      class="current"
      v-html="taxon.name"
    />
    <a
      v-else
      :class="{ 'taxonomy-tree-invalid-name': !taxon.isValid }"
      :href="makeBrowseUrl({ id: taxon.id, type: TAXON_NAME })"
      v-html="taxon.name"
    />
    <span v-if="taxon.total.valid || taxon.total.invalid"> - </span>
    <a
      v-if="taxon.total.valid"
      class="taxonomy-tree-status-tag taxonomy-tree-valid-name"
      :href="
        makeFilterLink({
          taxonId: taxon.id,
          validity: true
        })
      "
    >
      [{{ taxon.total.valid }}]
    </a>
    <a
      v-if="taxon.total.invalid"
      class="taxonomy-tree-status-tag taxonomy-tree-invalid-name"
      :href="
        makeFilterLink({
          taxonId: taxon.id,
          validity: false
        })
      "
    >
      [{{ taxon.total.invalid }}]
    </a>

    <TaxonomySynonyms
      v-if="taxon.synonyms?.length && !onlyValid"
      class="taxonomy-tree-invalid-name"
      :synonyms="taxon.synonyms"
    />
    <template v-if="(!taxon.isLoaded || taxon.isExpanded) && taxon.children">
      <ul class="taxonomy-tree">
        <template
          v-for="child in taxon.children"
          :key="child.id"
        >
          <TaxonomyTree
            v-if="child.id === currentId || !onlyValid || child.isValid"
            :taxon="child"
            :current-id="currentId"
            :only-valid="onlyValid"
          />
        </template>
      </ul>
    </template>
  </li>
</template>

<script setup>
import { ref } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import TaxonomyTree from './TaxonomyTree.vue'
import TaxonomySynonyms from './TaxonomySynonyms.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { makeBrowseUrl } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { TAXON_NAME } from '@/constants'

const props = defineProps({
  taxon: {
    type: Object,
    required: true
  },

  currentId: {
    type: Number,
    required: true
  },

  onlyValid: {
    type: Boolean,
    default: false
  }
})

const isLoading = ref(false)

function makeTaxonNode(taxon, children = []) {
  return {
    id: taxon.id,
    name: [taxon.cached_html, taxon.cached_author_year]
      .filter(Boolean)
      .join(' '),
    synonyms: taxon.synonyms,
    leaf: taxon.leaf_node,
    isExpanded: false,
    isValid: taxon.cached_is_valid,
    children: children || [],
    total: {
      valid: taxon.valid_descendants,
      invalid: taxon.invalid_descendants
    }
  }
}

function toggle() {
  if (!props.taxon.isExpanded && !props.taxon.isLoaded) {
    expandNode(props.taxon.id)
  }

  props.taxon.isExpanded = !props.taxon.isExpanded
}

function makeFilterLink({ taxonId, validity }) {
  return `${RouteNames.FilterNomenclature}?descendants=true&taxon_name_id=${taxonId}&validity=${validity}`
}

function expandNode(taxonId) {
  isLoading.value = true
  TaxonName.taxonomy(taxonId, {
    ancestors: false
  })
    .then(({ body }) => {
      const children = body.children.map((c) => makeTaxonNode(c))

      children.forEach((item, index) => {
        const current = props.taxon.children.find((c) => c.id === item.id)

        if (current) {
          children[index] = current
        }
      })

      props.taxon.isExpanded = true
      props.taxon.isLoaded = true
      props.taxon.children = children
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
