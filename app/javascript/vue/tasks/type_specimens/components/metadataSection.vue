<template>
  <div class="panel type-specimen-box">
    <spinner
      :show-spinner="false"
      :show-legend="false"
      v-if="!protonymId"
    />
    <div class="header flex-separate middle">
      <h3>Metadata</h3>
      <expand v-model="displayBody" />
    </div>
    <div
      class="body"
      v-if="displayBody"
    >
      <label>Type</label>
      <div class="flex-wrap-row separate-top separate-bottom">
        <template v-if="checkForTypeList">
          <ul class="flex-wrap-column no_bullets">
            <li
              v-for="(item, key) in types[taxon.nomenclatural_code]"
              :key="key"
            >
              <label class="capitalize">
                <input
                  v-model="type"
                  type="radio"
                  name="typetype"
                  :value="key"
                >
                {{ key }}
              </label>
            </li>
          </ul>
        </template>
      </div>
      <div class="field">
        <FormCitation
          v-if="!citationCreated"
          v-model="citation"
        />
        <div
          v-else
          class="horizontal-left-content"
        >
          <span>
            <span v-html="typeMaterial.origin_citation.object_tag" />
            <soft-validation
              class="margin-small-left"
              :global-id="typeMaterial.origin_citation.global_id"
            />
          </span>
          <span
            class="circle-button btn-delete"
            @click="removeCitation"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import Expand from 'components/expand.vue'
import Spinner from 'components/spinner.vue'
import SoftValidation from 'components/soft_validations/objectValidation.vue'
import FormCitation from 'components/Form/FormCitation.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Citation, TypeMaterial } from 'routes/endpoints'

export default {
  components: {
    Spinner,
    Expand,
    FormCitation,
    SoftValidation
  },

  computed: {
    citation: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial].origin_citation_attributes
      },
      set (value) {
        this.$store.commit(MutationNames.SetCitation, value)
      }
    },

    type: {
      get () {
        return this.$store.getters[GetterNames.GetType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetType, value)
      }
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    protonymId () {
      return this.$store.getters[GetterNames.GetProtonymId]
    },

    checkForTypeList () {
      return this.types && this.taxon
    },

    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },

    citationCreated () {
      return !!this.typeMaterial?.origin_citation
    }
  },

  data () {
    return {
      displayBody: true,
      types: undefined
    }
  },

  created () {
    TypeMaterial.types().then(response => {
      this.types = response.body
    })
  },

  methods: {
    removeCitation () {
      Citation.destroy(this.typeMaterial.origin_citation.id).then(() => {
        this.typeMaterial.origin_citation = undefined
      })
    }
  }
}
</script>
