<template>
  <fieldset>
    <legend>Namespace</legend>
    <switch-component
      class="separate-bottom"
      name="namespace"
      :options="options"
      v-model="view"
    />
    <div
      v-if="view == 'search'"
      class="field">
      <autocomplete
        url="/namespaces/autocomplete"
        label="label_html"
        min="2"
        placeholder="Namespaces"
        @getItem="setNamespace"
        param="term"
      />
    </div>
    <div v-else>
      <ul class="no_bullets">
        <li
          v-for="item in lists[view]"
          :key="item.id">
          <label>
            <input 
              type="radio"
              :checked="item.id == value"
              @click="setNamespace(item)">
            {{ item.object_tag }}
          </label>
        </li>
      </ul>
    </div>
  </fieldset>
</template>

<script>

  import SwitchComponent from 'components/switch'
  import Autocomplete from 'components/autocomplete'
  import CRUD from '../../request/crud.js'

  import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'

  export default {
    mixins: [CRUD],
    components: {
      Autocomplete,
      SwitchComponent
    },
    props: {
      objectType: {
        type: String,
        required: true
      },
      value: {

      }
    },
    data() {
      return {
        view: '',
        options: [],
        lists: [],
        namespace_id: undefined
      }
    },
    mounted() {
      this.getList(`/namespaces/select_options?klass=${this.objectType}`).then(response => {
        this.lists = response.body
        this.options = OrderSmartSelector(Object.keys(this.lists))
        this.options.push('search')
      })
    },
    methods: {
      setNamespace(value) {
        this.$emit('onLabelChange', (value.hasOwnProperty('label') ? value.label : value.name))
        this.$emit('input', value.id)
      }
    }
  }
</script>
