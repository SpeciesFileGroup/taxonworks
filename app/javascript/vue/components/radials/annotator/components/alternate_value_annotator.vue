<template>
  <div class="alternate_values_annotator">
    <div>
      <div class="switch-radio">
        <template v-for="(item, key, index) in typeList">
          <input
            v-model="alternate_value.type"
            :value="key"
            :id="`alternate_values-picker-${index}`"
            name="alternate_values-picker-options"
            type="radio"
            class="normal-input button-active"
          >
          <label
            :for="`alternate_values-picker-${index}`"
            class="capitalize">{{ item }}
          </label>
        </template>
      </div>
    </div>
    <div v-if="alternate_value.type">
      <ul class="no_bullets content">
        <li v-for="(item, key) in values">
          <label>
            <input
              type="radio"
              v-model="alternate_value.alternate_value_object_attribute"
              :value="key">
            "{{ key }}" -> {{ item }}
          </label>
        </li>
      </ul>

      <autocomplete
        class="field"
        v-if="alternate_value.type == 'AlternateValue::Translation'"
        url="/languages/autocomplete"
        label="label"
        min="2"
        placeholder="Language"
        @getItem="alternate_value.language_id = $event.id"
        param="term"/>

      <div class="separate-bottom">
        <div class="field">
          <input type="text" class="normal-input" v-model="alternate_value.value" placeholder="Value">
        </div>
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createNew()">
          Create
        </button>
      </div>
    </div>

    <display-list
      label="object_tag"
      :list="list"
      :edit="true"
      @edit="note = $event"
      @delete="removeItem"
      class="list"/>
  </div>
</template>
<script>

  import CRUD from '../request/crud.js'
  import annotatorExtend from '../components/annotatorExtend.js'
  import autocomplete from 'components/ui/Autocomplete.vue'
  import displayList from './displayList.vue'

  export default {
    mixins: [CRUD, annotatorExtend],
    components: {
      displayList,
      autocomplete
    },
    computed: {
      validateFields() {
        return (this.alternate_value.value &&
          this.alternate_value.alternate_value_object_attribute)
      }
    },
    mounted: function () {
      var that = this
      this.getList(`/alternate_values/${encodeURIComponent(this.globalId)}/metadata`).then(response => {
        that.values = response.body
      })
    },
    data: function () {
      return {
        values: undefined,
        typeList: {
          'AlternateValue::Translation': 'translation',
          'AlternateValue::Abbreviation': 'abbreviation',
          'AlternateValue::Misspelling': 'misspelled',
          'AlternateValue::AlternateSpelling': 'alternate spelling'
        },
        alternate_value: this.newAlternate()
      }
    },
    methods: {
      newAlternate() {
        return {
          type: undefined,
          value: undefined,
          language_id: undefined,
          alternate_value_object_attribute: undefined,
          annotated_global_entity: decodeURIComponent(this.globalId)
        }
      },
      createNew() {
        this.create('/alternate_values', {alternate_value: this.alternate_value}).then(response => {
          this.list.push(response.body)
          this.alternate_value = this.newAlternate()
        })
      }
    }
  }
</script>
<style lang="scss">
  .radial-annotator {
    .alternate_values_annotator {
      .field input {
        width: 100%;
      }
      .switch-radio {
        label {
          min-width: 95px;
        }
      }
      li {
        border-right: 0px;
        padding-left: 0px;
      }
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
    }
  }
</style>
