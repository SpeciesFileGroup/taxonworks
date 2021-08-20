<template>
  <div>
    <table-list 
      :header="header"
      :annotator="true"
      :types="types"
      :list="listWithCreators"
      @edit="editItem"
      @delete="removeItem"/>
  </div>
</template>

<script>

import TableList from './table.vue'
import AjaxCall from 'helpers/ajaxCall'
import { ProjectMember } from 'routes/endpoints'

export default {
  components: { TableList },

  props: {
    list: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      header: ['Type', 'Object type', 'Object', 'Annotation', 'Value', 'Object attribute', 'Created by', 'Created at', ''],
      types: {
        Attribution: {
          attributes: ['base_class', 'attribution_object_type', ['annotated_object', 'object_tag'], 'object_tag', '', '', 'created_by', 'created_at']
        },
        Tag: {
          attributes: ['base_class', 'tag_object_type', ['annotated_object', 'object_tag'], ['keyword', 'object_tag'], 'value', 'object_attribute', 'created_by', 'created_at']
        },
        Confidence: {
          attributes: ['base_class', 'confidence_object_type', ['annotated_object', 'object_tag'], ['confidence_level', 'object_tag'], 'value', 'object_attribute','created_by', 'created_at']
        },
        DataAttribute: {
          attributes: ['base_class', 'attribute_subject_type', ['annotated_object', 'object_tag'], ['controlled_vocabulary_term', 'name'], ['controlled_vocabulary_term', 'definition'], '', 'created_by', 'created_at']
        },
        Note: {
          attributes: ['base_class', 'note_object_type', ['annotated_object', 'object_tag'], 'annotation', 'text', 'object_attribute', 'created_by', 'created_at']
        },
        AlternateValue: {
          attributes: ['base_class', 'alternate_value_object_type', ['annotated_object', 'object_tag'], 'type', 'object_tag', 'alternate_value_object_attribute', 'created_by', 'created_at']
        },
        ImportAttribute: {
          attributes: ['base_class', 'attribute_subject_type', ['annotated_object', 'object_tag'], 'predicate_name', 'value', 'object_attribute', 'created_by', 'created_at']
        },
        InternalAttribute: {
          attributes: ['base_class', 'attribute_subject_type', ['annotated_object', 'object_tag'], 'predicate_name', 'value', 'object_attribute', 'created_by', 'created_at']
        },
      },
      listWithCreators: [],
      membersList: []
    }
  },

  watch: {
    list (newVal) {
      this.listWithCreators = this.setAuthorsToList(newVal)
    }
  },

  created () {
    ProjectMember.all().then(response => {
      this.membersList = response.body
    })
  },

  methods: {
    setAuthorsToList(list) {
      list.forEach((item, index) => {
        const member = this.membersList.find((o) => o.user.id === item.created_by_id)

        if (member) {
          list[index]['created_by'] = member.user.name
        }
      })
      return list
    },

    removeItem(item) {
      AjaxCall('delete', `${item.object_url}.json`).then(response => {
        const index = this.listWithCreators.findIndex(obj => (obj.id === item.id && obj.base_class === item.base_class))

        if (index > -1) {
          this.listWithCreators.splice(index, 1)
        }
        TW.workbench.alert.create('Annotation was successfully deleted.', 'notice')
      })
    },

    editItem (item) {
      window.open(`${item.annotated_object.object_url}/edit`, '_blank')
    }
  }
}
</script>
