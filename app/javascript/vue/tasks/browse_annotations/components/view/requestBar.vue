<template>
  <div v-if="url">
    <div class="panel content">
      <div class="flex-separate middle">
        <span>
          JSON Request:
          <a
            :href="url"
            target="_blank">{{ decodeURIComponent(url) }}
          </a>
          <span>({{ total }} records.)</span>
        </span>
        <div>
          <csv-button
            :list="newList"
            :options="{ fields }" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import CsvButton from 'components/csvButton'

export default {
  components: { CsvButton },

  props: {
    url: {
      type: String,
      default: ''
    },
    total: {
      type: Number,
      default: 0
    },
    list: {
      type: Array,
      required: true
    },
    type: {
      type: String
    }
  },

  computed: {
    fields () {
      if (this.type) {
        return this.types[this.type]
      }
      return []
    },

    newList () {
      if (this.type) {
        const temp = []
        this.list.forEach((item, index) => {
          item.annotated_object.object_tag = this.convertToText(item.annotated_object.object_tag)
          temp.push(item)
        })
        return temp
      } else {
        return this.list
      }
    }
  },

  data () {
    return {
      types: {
        tags: ['base_class', 'tag_object_type', { label: 'Annotated object', value: 'annotated_object.object_tag' }, { label: 'Keyword', value: 'keyword.object_tag' }, 'value', 'object_attribute', 'created_by', 'created_at'],
        confidences: ['base_class', 'confidence_object_type', { label: 'Annotated object', value: 'annotated_object.object_tag' }, { label: 'Confidence level', value: 'confidence_level.name' }, 'value', 'object_attribute', 'created_by', 'created_at'],
        notes: ['base_class', 'note_object_type', { label: 'Annotated object', value: 'annotated_object.object_tag' }, 'annotation', 'text', 'object_attribute', 'created_by', 'created_at'],
        alternate_values: ['base_class', 'alternate_value_object_type', { label: 'Annotated object', value: 'annotated_object.object_tag' }, 'annotation', { label: 'Alternate value', value: 'alternate_value.type' }, 'value', 'attribute_column', 'created_by', 'created_at'],
        importAttributes: ['base_class', 'attribute_subject_type', { label: 'Annotated object', value: 'annotated_object.object_tag' }, 'predicate_name', 'value', 'object_attribute', 'created_by', 'created_at'],
        internalAttributes: ['base_class', 'attribute_subject_type', { label: 'Annotated object', value: 'annotated_object.object_tag' }, 'predicate_name', 'value', 'object_attribute', 'created_by', 'created_at']
      }
    }
  },

  methods: {
    convertToText (htmlString) {
      const temp = document.createElement('div')
      temp.innerHTML = htmlString
      return temp.textContent || temp.innerText || ''
    }
  }
}
</script>
