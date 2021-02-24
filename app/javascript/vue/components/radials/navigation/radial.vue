<template>
  <div v-if="!deleted">
    <div class="radial-annotator">
      <modal
        v-if="display"
        :container-style="{ backgroundColor: 'transparent', boxShadow: 'none' }"
        @close="closeModal()">
        <h3
          slot="header"
          class="flex-separate">
          <span v-html="title" />
          <span
            v-if="metadata"
            class="separate-right"> {{ metadata.type }}</span>
        </h3>
        <div
          slot="body"
          class="flex-separate">
          <spinner v-if="loading" />
          <div class="radial-annotator-menu">
            <div>
              <radial-menu
                v-if="menuCreated"
                :menu="menuOptions"
                :circle-style="pinStyle"
                @selected="selectedRadialOption($event)"
                @contextmenu="selectedRadialOption($event, '_blank'); closeModal()"
                width="400"
                height="400"/>
            </div>
          </div>
          <div
            class="radial-annotator-template panel"
            :style="{ 'max-height': windowHeight(), 'min-height': windowHeight() }"
            v-if="currentView">
            <h2 class="capitalize view-title">
              {{ currentView.replace("_"," ") }}
            </h2>
            <component
              class="radial-annotator-container"
              :is="(currentView ? currentView + 'Component' : undefined)"
              :type="currentView"
              :metadata="metadata"
              :global-id="globalId"
              @onSelectedGlobalId="loadMetadata"
              @updateCount="setTotal"/>
          </div>
          <destroy-confirmation
            v-if="showDestroyModal"
            @close="showDestroyModal = false"
            @confirm="destroyObject"/>
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

import RadialMenu from 'components/radialMenu.vue'
import Modal from 'components/modal.vue'
import Spinner from 'components/spinner.vue'

import CRUD from './request/crud'
import Icons from './images/icons.js'

import RecentComponent from './components/recent.vue'
import DestroyConfirmation from './components/DestroyConfirmation'
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
  name: 'RadialNavigation',
  components: {
    all_tasksComponent,
    RecentComponent,
    RadialMenu,
    Modal,
    Spinner,
    DestroyConfirmation
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
      default: 'Navigate radial'
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
      showDestroyModal: false,
      menuOptions: [],
      customOptions: ['alltasks', 'circleButton'],
      defaultSlices: [
        {
          label: defaultOptions.New,
          event: defaultOptions.New,
          size: 30,
          icon: {
            url: Icons.New,
            width: '20',
            height: '20'
          }
        },
        {
          label: defaultOptions.Destroy,
          event: defaultOptions.Destroy,
          size: 30,
          icon: {
            url: Icons.Destroy,
            width: '20',
            height: '20'
          }
        },
        {
          label: defaultOptions.Edit,
          event: defaultOptions.Edit,
          size: 30,
          icon: {
            url: Icons.Edit,
            width: '20',
            height: '20'
          }
        },
        {
          label: defaultOptions.Show,
          event: defaultOptions.Show,
          size: 30,
          icon: {
            url: Icons.Show,
            width: '20',
            height: '20'
          }
        }]
    }
  },
  computed: {
    menuCreated () {
      return this.menuOptions.length > 0
    },
    isPinned () {
      return this.metadata['pinboard_item']
    },
    pinStyle () {
      return {
        icon: {
          url: Icons.Pin,
          width: '20',
          height: '20'
        },
        background: this.isPinned ? '#F44336' : '#9ccc65',
        backgroundHover: this.isPinned ? '#CE3430' : '#81a553'
      }
    }
  },
  methods: {
    selectedRadialOption (selected, target = '_self') {
      if (Object.keys(defaultOptions).includes(selected) || this.customOptions.includes(selected)) {
        this.currentView = undefined
        switch (selected) {
          case 'circleButton':
            this.isPinned ? this.destroyPin() : this.createPin()
            break
          case defaultOptions.Recent:
            this.currentView = 'Recent'
            break
          case defaultOptions.Edit:
            window.open(this.metadata['edit'] ? this.metadata.edit : `${this.metadata.resource_path}/edit`, target)
            break
          case defaultOptions.New:
            window.open(this.metadata['new'] ? this.metadata.new : `${this.metadata.resource_path.substring(0, this.metadata.resource_path.lastIndexOf('/'))}/new`, target)
            break
          case defaultOptions.Show:
            window.open(this.metadata.resource_path, target)
            break
          case defaultOptions.Destroy:
            this.showDestroyModal = true
            break
          case 'alltasks':
            this.currentView = 'all_tasks'
            break
        }
      } else {
        window.open(this.metadata.tasks[selected].path, target)
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
        this.title = this.metadata.object_label
        this.menuOptions = (this.metadata.hasOwnProperty('tasks') ? this.createMenuOptions(this.metadata.tasks) : [])
        if (this.metadata.hasOwnProperty('recent_url')) {
          this.menuOptions.push({
            label: defaultOptions.Recent,
            event: defaultOptions.Recent,
            size: 30,
            icon: {
              url: Icons.Recent,
              width: '20',
              height: '20'
            }
          })
        }
        this.addDefaultOptions()
        this.loading = false
      })
    },
    createMenuOptions (tasks) {
      const menu = []
      const keys = Object.keys(tasks)

      for (var i = 0; i < this.maxTaskInPie && i < keys.length; i++) {
        const key = keys[i]
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
      if (keys.length > this.maxTaskInPie) {
        menu.push({
          label: 'All tasks',
          event: 'alltasks',
          icon: {
            url: Icons.AllTasks,
            width: '20',
            height: '20'
          }
        })
      }
      return menu
    },
    addDefaultOptions () {
      const filterOptions = this.filterOptions
      if (!this.metadata.destroy) {
        filterOptions.push(defaultOptions.Destroy)
      }
      this.defaultSlices.forEach(slice => {
        const founded = filterOptions.find(option => {
          return option.toLowerCase() == slice.label.toLowerCase()
        })

        if (!founded) {
          this.menuOptions.push(slice)
        }
      })
    },
    setTotal (total) {
      var that = this
      const position = this.menuOptions.findIndex(function (element) {
        return element.event == that.currentView
      })
      this.menuOptions[position].total = total
    },
    eventClose () {
      const event = new CustomEvent('radialObject:close', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },
    eventDestroy () {
      const event = new CustomEvent('radialObject:destroy', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },
    windowHeight () {
      return ((window.innerHeight - 100) > 650 ? 650 : window.innerHeight - 100) + 'px !important'
    },
    createPin () {
      const pinItem = {
        pinboard_item: {
          pinned_object_id: this.metadata.id,
          pinned_object_type: this.metadata.type,
          is_inserted: true
        }
      }
      this.create('/pinboard_items', pinItem).then(response => {
        this.$set(this.metadata, 'pinboard_item', { id: response.body.id })
        TW.workbench.pinboard.addToPinboard(response.body)
        TW.workbench.alert.create('Pinboard item was successfully created.', 'notice')
      })
    },
    destroyPin: function () {
      this.destroy(`/pinboard_items/${this.metadata.pinboard_item.id}`, { _destroy: true }).then(response => {
        TW.workbench.alert.create('Pinboard item was successfully destroyed.', 'notice')
        TW.workbench.pinboard.removeItem(this.metadata.pinboard_item.id)
        this.$delete(this.metadata, 'pinboard_item')
      })
    },
    destroyObject () {
      this.showDestroyModal = false
      this.destroy(`${this.metadata.resource_path}.json`).then((response) => {
        TW.workbench.alert.create(`${this.metadata.type} was successfully destroyed.`, 'notice')
        if (this.globalId === this.metadata.globalId) {
          this.eventDestroy()
          this.deleted = true
        }
        if (window.location.pathname == this.metadata.resource_path) {
          window.open(`/${window.location.pathname.split('/')[1]}`, '_self')
        } else {
          window.open(this.metadata.resource_path.substring(0, this.metadata.resource_path.lastIndexOf('/')), '_self')
        }
      })
    }
  }
}
</script>
