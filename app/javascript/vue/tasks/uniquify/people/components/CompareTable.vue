<template>
  <div>
    <div class="horizontal-left-content align-start">
      <div class="column-buttons">
        <h2>&nbsp;</h2>
        <div class="horizontal-left-content">
          <button
            type="button"
            class="button normal-input button-default separate-right"
            :disabled="!(Object.keys(selected).length && selectedMergePerson)"
            @click="$emit('flip', personIndex)"
          >
            Flip
          </button>
          <ConfirmationModal ref="confirmationModal" />
          <button
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
        <tr v-if="selected.id">
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
                :href="`/people/${selectedMergePerson.id}`"
              >
                {{ selectedMergePerson.cached }}
              </a>
              <radial-annotator
                v-if="selectedMergePerson.global_id"
                :global-id="selectedMergePerson.global_id"
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
              repeated: (value !== selectedMergePerson[key]) && selectedMergePerson[key]
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
              v-html="humanizeValue(selectedMergePerson[key])"
            />
          </tr>
        </template>
      </tbody>
    </table>

    <TableGrid
      :columns="2"
      :gap="12"
    >
      <div>
        <table-person-roles
          v-show="selected.id"
          title="Selected role types"
          :person="selected"
        />
        <table-annotations
          :person="selected"
          title="Selected annotations"
        />
      </div>
      <div>
        <table-person-roles
          v-show="selectedMergePerson.id"
          title="Merge role types"
          :person="selectedMergePerson"
        />
        <table-annotations
          :person="selectedMergePerson"
          title="Merge annotations"
        />
      </div>
    </TableGrid>
  </div>
</template>

<script>

import TableAnnotations from './Table/TableAnnotations.vue'
import TablePersonRoles from './Table/TableDescription.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import SwitchComponent from 'components/switch'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import { capitalize, humanize } from 'helpers/strings'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'

export default {
  name: 'CompareComponent',

  components: {
    TablePersonRoles,
    TableAnnotations,
    RadialAnnotator,
    SwitchComponent,
    ConfirmationModal,
    TableGrid
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

    selectedMergePerson () {
      return this.mergeList[this.personIndex] || {}
    },

    peopleList () {
      return this.mergeList.map(p => p.cached)
    },

    mergeList () {
      return this.$store.getters[GetterNames.GetMergePeople]
    },

    selected () {
      return this.$store.getters[GetterNames.GetSelectedPerson]
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

    async sendMerge () {
      const confirmed = await this.$refs.confirmationModal.show({
        title: 'Merge people',
        message: 'This will merge all selected match people to selected person.',
        okButton: 'Merge',
        confirmationWord: 'merge',
        typeButton: 'submit'
      })

      if (confirmed) {
        this.$store.dispatch(ActionNames.ProcessMerge)
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
