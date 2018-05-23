<template>
  <div>
    <table-list 
      :attributes="types[type].attributes"
      :header="types[type].header"
      :list="listWithCreators"/>
  </div>
</template>

<script>

import TableList from '../../../components/table_list'

export default {
  components: {
    TableList
  },
  props: {
    list: {
      type: Array,
      required: true
    },
    type: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      types: {
        tags: {
          header: ['Type', 'Object type', 'Object', 'Annotation', 'Created by', 'Created at'],
          attributes: ['@Tag', 'tag_object_type', 'object_tag', ['keyword', 'object_tag'], 'created_by', 'created_at']
        },
        confidences: {
          header: ['Type', 'Object type', 'Object', 'Annotation', 'Created by', 'Created at'],
          attributes: ['@Confidences', 'confidence_object_type', 'object_tag', ['confidence_level', 'object_tag'], 'created_by', 'created_at']
        },
        notes: {
          header: ['Type', 'Object type', 'Object', 'Note', 'Created by', 'Created at'],
          attributes: ['@Note', 'note_object_type', 'object_tag', 'text', 'created_by', 'created_at']
        },
        alternate_values: {
          header: ['Type', 'Object type', 'Object', 'Annotation', 'Value', 'Object attribute', 'Created by', 'Created at'],
          attributes: ['@Alternate value', 'alternate_value_object_type', 'object_tag', ['alternate_value', 'type'], 'value', 'attribute_column', 'created_by', 'created_at']
        },
        data_attributes: {
          header: ['Type', 'Object type', 'Object', 'Annotation', 'Value', 'Created by', 'Created at'],
          attributes: ['type', 'attribute_subject_type', 'object_tag', 'predicate_name', 'value', 'created_by', 'created_at']
        }
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
    }
  }
}
</script>