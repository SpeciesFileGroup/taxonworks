<template>
  <FacetContainer>
    <h3>Authors</h3>
    <div class="field label-above">
      <label>Author as text string</label>
      <input
        type="text"
        class="full_width"
        v-model="source.author"
      />
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="source.exact_author"
        />
        Exact
      </label>
    </div>
    <fieldset>
      <legend>Author as role</legend>
      <smart-selector
        model="people"
        target="Author"
        :autocomplete-params="{
          roles: ['SourceAuthor', 'SourceEditor']
        }"
        label="cached"
        @selected="addAuthor"
      />
      <label>
        <input
          v-model="source.author_id_or"
          type="checkbox"
        />
        Any
      </label>
    </fieldset>
    <display-list
      :list="authors"
      label="object_tag"
      :delete-warning="false"
      @delete-index="removeAuthor"
    />
  </FacetContainer>
</template>

<script>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { People } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    DisplayList,
    FacetContainer
  },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    source: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data() {
    return {
      authors: []
    }
  },

  watch: {
    modelValue: {
      handler(newVal, oldVal) {
        if (!newVal?.author_id?.length && oldVal?.author_id?.length) {
          this.authors = []
        }
      },
      deep: true
    },

    authors: {
      handler(newVal) {
        this.source.author_id = this.authors.map((author) => author.id)
      },
      deep: true
    }
  },

  mounted() {
    const params = URLParamsToJSON(location.href)

    this.source.author = params.author
    this.source.exact_author = params.exact_author
    this.source.author_id_or = params.author_id_or
    if (params.author_id) {
      params.author_id.forEach((id) => {
        People.find(id).then((response) => {
          this.addAuthor(response.body)
        })
      })
    }
  },

  methods: {
    addAuthor(author) {
      if (!this.source.author_id.includes(author.id)) {
        this.authors.push(author)
      }
    },

    removeAuthor(index) {
      this.authors.splice(index, 1)
    }
  }
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
