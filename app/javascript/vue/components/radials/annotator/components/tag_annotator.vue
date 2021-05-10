<template>
  <div class="tag_annotator">
    <div
      class="switch-radio separate-bottom"
      v-if="preferences">
      <template
      v-for="(item, index) in tabOptions">
        <template v-if="item == 'new keyword' || preferences[item].length && preferences[item].find(keyword => { return !tagAlreadyCreated(keyword) })">
          <input
            v-model="view"
            :value="item"
            :id="`switch-picker-${index}`"
            name="switch-picker-options"
            type="radio"
            class="normal-input button-active"
          >
          <label
            :for="`switch-picker-${index}`"
            class="capitalize">{{ item }}
          </label>
        </template>
      </template>
    </div>

    <modal
      class="transparent-modal"
      v-if="view == 'all'"
      @close="view = 'new keyword'">
      <h3 slot="header">Keywords</h3>
      <div slot="body">
        <template v-for="keyword in preferences[view]">
          <button
            v-if="!tagAlreadyCreated(keyword)"
            @click="createWithId(keyword.id)"
            type="button"
            class="button normal-input button-submit margin-small-right margin-small-bottom"> 
            <span v-html="keyword.object_tag"/>
          </button>
        </template>
      </div>
    </modal>

    <template v-if="preferences && view != 'new keyword' && view != 'all'">
      <div class="field separate-bottom">
        <template v-for="keyword in preferences[view]">
          <button
            v-if="!tagAlreadyCreated(keyword)"
            @click="createWithId(keyword.id)"
            type="button"
            class="normal-input button-submit tag_button"> {{ keyword.name }} </button>
        </template>
      </div>
    </template>

    <div class="separate-bottom" v-if="view == 'new keyword'">
      <autocomplete
        url="/controlled_vocabulary_terms/autocomplete"
        label="label"
        min="2"
        placeholder="Keyword"
        :clear-after="true"
        :add-params="{'type[]' : 'Keyword'}"
        @getInput="tag.keyword_attributes.name = $event"
        @getItem="createWithId($event.id)"
        class="separate-bottom"
        param="term"/>
      <textarea
        class="separate-bottom"
        placeholder="Definition... (minimum is 20 characters)"
        v-model="tag.keyword_attributes.definition"/>
      <div>
        <button
          @click="createWithoutId()"
          :disabled="!validateFields"
          class="button button-submit normal-input separate-bottom"
          type="button">Create
        </button>
      </div>
    </div>

    <display-list
      :label="['keyword', 'name']"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import autocomplete from 'components/ui/Autocomplete.vue'
import modal from 'components/modal.vue'
import displayList from './displayList.vue'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    autocomplete,
    modal,
    displayList
  },
  mounted: function () {
    this.loadTabList('Keyword')
  },
  computed: {
    validateFields () {
      return (this.tag.keyword_attributes.name.length > 1 &&
						this.tag.keyword_attributes.definition.length > 20)
    }
  },
  data: function () {
    return {
      preferences: undefined,
      view: 'quick',
      tabOptions: ['quick', 'recent', 'pinboard', 'all'],
      tag: {
        keyword_attributes: {
          name: '',
          definition: ''
        },
        annotated_global_entity: decodeURIComponent(this.globalId)
      }
    }
  },
  methods: {
    createWithId (id) {
      let tag = {
        tag: {
          keyword_id: id,
          annotated_global_entity: decodeURIComponent(this.globalId)
        }
      }
      this.create('/tags', tag).then(response => {
        this.list.push(response.body)
      })
    },
    createWithoutId () {
      this.create('/tags', { tag: this.tag }).then(response => {
        this.list.push(response.body)
      })
    },
    tagAlreadyCreated (keyword) {
      return this.list.find(item => { return keyword.id == item.keyword_id })
    },
    loadTabList (type) {
      let tabList
      let allList
      let promises = []
      let that = this

      promises.push(this.getList(`/keywords/select_options?klass=${this.objectType}`).then(response => {
        tabList = response.body
      }))
      promises.push(this.getList(`/controlled_vocabulary_terms.json?type[]=${type}`).then(response => {
        allList = response.body
      }))

      Promise.all(promises).then(() => {
        tabList['all'] = allList
        that.preferences = tabList
      })
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
	.tag_annotator {
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.vue-autocomplete-input {
			width: 100%;
		}
    .switch-radio label {
      width: 80px;
    }
	}
}
</style>
