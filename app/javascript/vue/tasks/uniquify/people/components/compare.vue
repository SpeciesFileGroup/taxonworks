<template>
  <div>
    <div class="horizontal-left-content align-start">
      <div class="column-buttons">
        <h2>&nbsp;</h2>
        <div class="horizontal-left-content">
          <button
            type="button"
            class="button normal-input button-default separate-right"
            :disabled="!(Object.keys(selected).length && Object.keys(merge).length)"
            @click="$emit('flip', personIndex)"
          >
            Flip
          </button>
          <confirm-modal
            v-if="mergeList.length"
            @on-accept="$emit('merge')"
          />
          <button
            v-else
            class="button normal-input button-submit"
            @click="sendMerge"
            :disabled="isMergeEmpty"
          >
            Merge people
          </button>
        </div>
      </div>
      <div class="title-person">
        <h2>Selected person</h2>
        <template v-if="selectedEmpty">
          <p>This person will remain.</p>
        </template>
      </div>
      <div class="title-merge">
        <h2>Person to merge</h2>
        <template v-if="!isMergeEmpty">
          <p data-icon="warning">
            This person(s) will be deleted.
          </p>
          <switch-component
            v-model="personIndex"
            use-index
            :options="peopleList"
          />
        </template>
      </div>
    </div>
    <table>
      <tbody>
        <tr v-if="Object.keys(selected).length">
          <td />
          <td>
            <div class="horizontal-left-content">
              <a
                target="_blank"
                :href="`/people/${selected.id}`"
              >
                {{ selected.cached }}
              </a>
              <radial-annotator
                v-if="selected.global_id"
                :global-id="selected.global_id"
              />
            </div>
          </td>
          <td>
            <div class="horizontal-left-content">
              <a
                target="_blank"
                :href="`/people/${merge.id}`"
              >
                {{ merge.cached }}
              </a>
              <radial-annotator
                v-if="merge.global_id"
                :global-id="merge.global_id"
              />
            </div>
          </td>
        </tr>
        <template
          v-for="(value, key, index) in selected"
          :key="key"
        >
          <tr
            v-if="!isNestedProperty(value)"
            class="contextMenuCells"
            :class="{
              even: (index % 2 == 0),
              repeated: (value !== merge[key]) && merge[key]
            }"
          >
            <td
              class="column-property"
              v-text="humanizeValue(key)"
            />
            <td
              class="column-person"
              v-html="humanizeValue(value)"
            />
            <td
              class="column-merge"
              v-html="humanizeValue(merge[key])"
            />
          </tr>
        </template>
      </tbody>
    </table>
    <div
      class="margin-medium-top"
      v-if="Object.keys(selected).length || Object.keys(merge).length"
    >
      <ul class="no_bullets context-menu">
        <li class="middle">
          <div class="circle-info-project in-project margin-small-right" />
          <span>In project</span>
        </li>
        <li class="middle">
          <div class="circle-info-project no-in-project margin-small-right" />
          <span>Not in project</span>
        </li>
        <li class="middle">
          <div class="circle-info-project nulled margin-small-right" />
          <span>Not determinated</span>
        </li>
      </ul>
    </div>

    <div class="horizontal-left-content align-start">
      <table-person-roles
        :class="{ 'separate-right': Object.keys(merge).length }"
        v-show="Object.keys(selected).length"
        title="Selected role types"
        :person="selected"
      />
      <table-person-roles
        :class="{ 'separate-left': Object.keys(selected).length }"
        v-show="Object.keys(merge).length"
        title="Merge role types"
        :person="merge"
      />
    </div>
    <table-roles
      v-if="selected['roles'] && selected['roles'].length"
      title="Selected roles"
      :list="selected['roles']"
    />
    <table-roles
      v-if="merge['roles'] && merge['roles'].length"
      title="Merge roles"
      :list="merge['roles']"
    />
    <table-annotations
      :person="selected"
      title="Selected annotations"
    />
    <table-annotations
      :person="merge"
      title="Merge annotations"
    />
  </div>
</template>

<script>

import TableRoles from './tableRoles'
import TableAnnotations from './tableAnnotations'
import TablePersonRoles from './roles_table'
import RadialAnnotator from 'components/radials/annotator/annotator'
import SwitchComponent from 'components/switch'
import ConfirmModal from './confirmModal.vue'
import { capitalize, humanize } from 'helpers/strings'

export default {
  components: {
    TablePersonRoles,
    TableAnnotations,
    TableRoles,
    RadialAnnotator,
    SwitchComponent,
    ConfirmModal
  },

  name: 'CompareComponent',

  props: {
    selected: {
      type: [Object, Array],
      default: () => ({})
    },

    mergeList: {
      type: Array,
      required: true
    }
  },

  emits: [
    'merge',
    'flip'
  ],

  computed: {
    selectedEmpty () {
      return Object.keys(this.selected).length > 0
    },

    isMergeEmpty () {
      return this.mergeList.length === 0
    },

    merge () {
      return this.mergeList[this.personIndex] || {}
    },

    peopleList () {
      return this.mergeList.map(p => p.cached)
    }
  },

  data () {
    return {
      personIndex: 0
    }
  },

  methods: {
    isNestedProperty (value) {
      return (
        Array.isArray(value) ||
        (typeof value === 'object' && value != null)
      )
    },

    sendMerge () {
      if (window.confirm('Are you sure you want to merge?')) {
        this.$emit('merge')
      }
    },

    humanizeValue (value) {
      return capitalize(humanize(value))
    }
  }
}
</script>

<style lang="scss" scoped>
  .repeated {
    color: red
  }
  .no-difference {
    display: none
  }
  .column-property {
    min-width: 105px;
  }
  .column-buttons {
    min-width: 136px;
  }
  .column-person, .column-merge {
    min-width: 250px;
  }
  .title-merge, .title-person {
    min-width: 250px;
    padding-left: 1em;
    padding-right: 1em;
  }
  .circle-info-project {
    border-radius: 50%;
    width: 24px;
    height: 24px;
  }
  .nulled {
    background-color: #E5D2BE;
  }
  .in-project {
    background-color: #5D9ECE;
  }
  .no-in-project {
    background-color: #C38A8A;
  }
</style>
