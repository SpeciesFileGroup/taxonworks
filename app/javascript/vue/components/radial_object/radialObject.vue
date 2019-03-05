<template>
  <div v-if="!deleted">
    <div class="radial-annotator">
      <modal
        v-if="display"
        @close="closeModal()">
        <h3 slot="header">
          <span v-html="title"/>
        </h3>
        <div
          slot="body"
          class="flex-separate">
          <spinner v-if="loading"/>
          <div class="radial-annotator-menu">
            <div>
              <radial-menu
                v-if="menuCreated"
                :menu="menuOptions"
                @selected="selectedRadialOption"
                width="400"
                height="400"/>
            </div>
          </div>
          <div
            class="radial-annotator-template panel"
            :style="{ 'max-height': windowHeight(), 'min-height': windowHeight() }"
            v-if="currentView">
            <h3 class="capitalize view-title">{{ currentView.replace("_"," ") }}</h3>
            <component
              class="radial-annotator-container"
              :is="(currentView ? currentView + 'Component' : undefined)"
              :type="currentView"
              :metadata="metadata"
              :global-id="globalId"
              @onSelectedGlobalId="loadMetadata"
              @updateCount="setTotal"/>
          </div>
        </div>
      </modal>
      <span
        v-if="showBottom"
        :title="buttonTitle"
        type="button"
        class="circle-button"
        :class="[buttonClass]"
        @click="displayRadialObject()">Radial annotator
      </span>
    </div>
  </div>
</template>
<script>

  import radialMenu from '../radialMenu.vue'
  import modal from '../modal.vue'
  import spinner from '../spinner.vue'

  import CRUD from './request/crud'
  import Icons from './images/icons.js'

  import RecentComponent from './components/recent.vue'
  import all_tasksComponent from './components/allTasks.vue'


  const defaultOptions = {
    New: 'New',
    Edit: 'Edit',
    Destroy: 'Destroy',
    Recent: 'Recent',
    Show: 'Show'
  }

  export default {
    mixins: [CRUD],
    name: 'RadialObject',
    components: {
      all_tasksComponent,
      RecentComponent,
      radialMenu,
      modal,
      spinner,
    },
    props: {
      reload: {
        type: Boolean,
        default: false
      },
      globalId: {
        type: String,
        required: true
      },
      showBottom: {
        type: Boolean,
        default: true
      },
      buttonClass: {
        type: String,
        default: 'btn-radial-object'
      },
      buttonTitle: {
        type: String,
        default: 'Radial object'
      },
      maxTaskInPie: {
        type: Number,
        default: 4
      },
      components: {
        type: Object,
        default: () => {
          return {}
        }
      },
      filterOptions: {
        type: [String, Array],
        default: () => { return [] }
      }
    },
    data: function () {
      return {
        loading: false,
        currentView: undefined,
        display: false,
        globalIdSaved: undefined,
        metadata: undefined,
        title: 'Radial object',
        deleted: false,
        menuOptions: [],
        defaultSlices: [{
          label: defaultOptions.Recent,
          event: defaultOptions.Recent,
          size: 30
        },
        {
          label: defaultOptions.Destroy,
          event: defaultOptions.Destroy,
          size: 30
        },
        {
          label: defaultOptions.New,
          event: defaultOptions.New,
          size:30
        },
        {
          label: defaultOptions.Edit,
          event: defaultOptions.Edit,
          size:30
        },
        {
          label: defaultOptions.Show,
          event: defaultOptions.Show,
          size:30
        }]
      }
    },
    computed: {
      menuCreated() {
        return this.menuOptions.length > 0
      }
    },
    methods: {
      selectedRadialOption(selected) {

        if(Object.keys(defaultOptions).includes(selected) || selected == 'alltasks') {
          this.currentView = undefined
          switch(selected) {
            case defaultOptions.Recent: 
              this.currentView = 'Recent'
              break
            case defaultOptions.Edit:
              window.open(`${this.metadata.resource_path}/edit`, '_self')
              break
            case defaultOptions.New:
              window.open(`${this.metadata.resource_path}/new`, '_self')
              break
            case defaultOptions.Show:
              window.open(this.metadata.resource_path, '_self')
              break
            case defaultOptions.Destroy:
              if(window.confirm('Are you sure you want to destroy this record?')) {
                this.destroy(`${this.metadata.resource_path}.json`).then(() => {
                  TW.workbench.alert.create(`${this.metadata.type} was successfully destroyed.`, 'notice')
                  if(this.globalId == this.metadata.globalId) {
                    this.eventDestroy()
                    this.deleted = true
                  }
                })
              }
              break
            case 'alltasks':
              this.currentView = "all_tasks"
              break
          }
        }
        else {
          window.open(this.metadata.tasks[selected].path, '_self')
        }
      },
      closeModal () {
        this.display = false
        this.eventClose()
        this.$emit('close')
      },
      displayRadialObject () {
        this.display = true
        this.currentView = undefined
        this.loadMetadata(this.globalId)
      },
      loadMetadata (globalId) {
        if (globalId == this.globalIdSaved && this.menuCreated && !this.reload) return
        this.globalIdSaved = globalId
        this.loading = true

        this.getList(`/metadata/object_radial?global_id=${encodeURIComponent(globalId)}`).then(response => {
          this.metadata = response.body
          this.title = `${this.metadata.type}: ${this.metadata.object_label}`
          this.menuOptions = (this.metadata.hasOwnProperty('tasks') ? this.createMenuOptions(this.metadata.tasks) : [])
          this.addDefaultOptions()
          this.loading = false
        })
      },
      createMenuOptions (tasks) {
        let menu = []
        let keys = Object.keys(tasks)

        for(var i = 0; i < this.maxTaskInPie && i < keys.length; i++) {
          let key = keys[i]
          menu.push({
            label: tasks[key].name,
            event: key,
            icon: Icons[key] ? {
              url: Icons[key],
              width: '20',
              height: '20'
            } : undefined
          })
        }
        if(keys.length > this.maxTaskInPie) { 
          menu.push({
            label: 'All tasks',
            event: 'alltasks',
            icon: Icons['alltasks'] ? {
              url: Icons['alltasks'],
              width: '20',
              height: '20'
            } : undefined
          })
        }
        return menu
      },
      addDefaultOptions() {
        this.defaultSlices.forEach(slice => {

          let founded = this.filterOptions.find(option => {
            return option.toLowerCase() == slice.label.toLowerCase()
          })

          if(!founded) {
            this.menuOptions.unshift(slice)
          }
        })
      },
      setTotal(total) {
        var that = this
        let position = this.menuOptions.findIndex(function (element) {
          return element.event == that.currentView
        })
        this.menuOptions[position].total = total
      },
      eventClose() {
        let event = new CustomEvent('radialObject:close', {
          detail: {
            metadata: this.metadata
          }
        })
        document.dispatchEvent(event)
      },
      eventDestroy() {
        let event = new CustomEvent('radialObject:destroy', {
          detail: {
            metadata: this.metadata
          }
        })
        document.dispatchEvent(event)
      },
      windowHeight() {
        return ((window.innerHeight - 100) > 650 ? 650 : window.innerHeight-100) + 'px !important'
      }
    }
  }
</script>
<style lang="scss">

  .radial-annotator {
    .view-title {
      font-size: 18px;
      font-weight: 300;
    }
    .modal-close {
      top: 30px;
      right: 20px;
    }
    .modal-mask {
      background-color: rgba(0, 0, 0, 0.7);
    }
    .modal-container {
      box-shadow: none;
      background-color: transparent;
    }
    .modal-container {
      min-width: 1024px;
      width: 1200px;
    }
    .radial-annotator-template {
      border-radius: 3px;
      background: #FFFFFF;
      padding: 1em;
      width: 50%;
      max-width: 50%;
      min-height: 600px;
    }
    .radial-annotator-container {
      display: flex;
      height: 600px;
      flex-direction: column;
    }
    .radial-annotator-menu {
      padding-top: 1em;
      padding-bottom: 1em;
      width: 50%;
      min-height: 650px;
    }
    .annotator-buttons-list {
      overflow-y: scroll;
    }
    .save-annotator-button {
      width: 100px;
    }
  }

  .tag_button {
    padding-left: 12px;
    padding-right: 8px;
    width: auto !important;
    min-width: auto !important;
    cursor: pointer;
    margin: 2px;
    border: none;
    border-top-left-radius: 15px;
    border-bottom-left-radius: 15px;
  }
</style>
