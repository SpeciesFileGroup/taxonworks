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

export default {
  components: {
    TableList,
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      header: ['Type', 'Object type', 'Object', 'Annotation', 'Value', 'Object attribute', 'Created by', 'Created at', ''],
      types: {
        Tag: {
          attributes: ['type', 'tag_object_type', ['annotated_object', 'object_tag'], ['keyword', 'object_tag'], 'value', 'object_attribute', 'created_by', 'created_at']
        },
        Confidence: {
          attributes: ['type', 'confidence_object_type', ['annotated_object', 'object_tag'], ['confidence_level', 'object_tag'], 'value', 'object_attribute','created_by', 'created_at']
        },
        Note: {
          attributes: ['type', 'note_object_type', ['annotated_object', 'object_tag'], 'annotation', 'text', 'object_attribute', 'created_by', 'created_at']
        },
        Alternate_value: {
          attributes: ['type', 'alternate_value_object_type', ['annotated_object', 'object_tag'], 'annotation', ['alternate_value', 'type'], 'value', 'attribute_column', 'created_by', 'created_at']
        },
        ImportAttribute: {
          attributes: ['type', 'attribute_subject_type', ['annotated_object', 'object_tag'], 'predicate_name', 'value', 'object_attribute', 'created_by', 'created_at']
        },
        InternalAttribute: {
          attributes: ['type', 'attribute_subject_type', ['annotated_object', 'object_tag'], 'predicate_name', 'value', 'object_attribute', 'created_by', 'created_at']
        },
      },
      listWithCreators: [],
      membersList: []
    }
  },
  watch: {
    list(newVal) {
      this.listWithCreators = this.setAuthorsToList(newVal)
    }
  },
  mounted() {
    this.$http.get('/project_members.json').then(response => {
      this.membersList = response.body
    })
  },
  methods: {
    setAuthorsToList(list) {
      let that = this;

      list.forEach((item, index) => {
        let member = that.membersList.find((o) => { return o.user.id == item.created_by_id })

        if(member) {
          list[index]['created_by'] = member.user.name
        }
      })
      return list
    },
    removeItem(item) {
      this.$http.delete(`${item.object_url}.json`).then(response => {
        let index = this.listWithCreators.findIndex(obj => {
          return (obj.id == item.id && obj.base_class == item.base_class)
        })
        if(index > -1) {
          this.listWithCreators.splice(index, 1)
        }
        TW.workbench.alert.create('Annotation was successfully deleted.', 'notice')
      })
    },
    editItem(item) {
      window.open(`${item.annotated_object.object_url}/edit`, '_blank');
    }
  }
}
</script>
