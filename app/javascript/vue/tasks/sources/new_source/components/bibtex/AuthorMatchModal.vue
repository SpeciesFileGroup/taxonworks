<template>
  <Modal
    @close="$emit('close')"
    container-style="max-width: 900px; width: 90vw;"
  >
    <template #header>
      <h3>Match Authors to People</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Searching for matches..."
      />
      <div v-else-if="authorRows.length === 0">
        <p>No authors to match.</p>
      </div>
      <table
        v-else
        class="full_width"
      >
        <thead>
          <tr>
            <th>Author String</th>
            <th>Matches</th>
            <th>Select(ed)</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(row, index) in authorRows"
            :key="index"
          >
            <td class="author-string-cell">
              {{ row.originalString }}
            </td>
            <td class="matches-cell">
              <VSpinner
                v-if="row.isSearching"
                :legend="null"
              />
              <div v-else-if="row.matches.length === 0">
                <span class="no-matches">No matches found</span>
              </div>
              <div
                v-else
                class="matches-list"
              >
                <label
                  v-for="person in row.matches"
                  :key="person.id"
                  class="match-option"
                >
                  <input
                    type="radio"
                    :name="`author-match-${index}`"
                    :value="person.id"
                    v-model="row.selectedPersonId"
                    @change="
                      () => {
                        row.createdPerson = null
                        applySelections()
                      }
                    "
                  />
                  <span v-html="person.cached || person.name" />
                </label>
              </div>
            </td>
            <td class="create-cell">
              <div
                v-if="row.createdPerson"
                class="selected-person"
              >
                <span class="selected-text">
                  {{ row.alreadyExists ? 'Selected:' : 'Created:' }}
                  {{ row.createdPerson.cached }}
                </span>
              </div>
              <div
                v-else
                class="create-form"
              >
                <div class="form-fields">
                  <div class="field">
                    <label>Given name</label>
                    <input
                      v-model="row.newPersonForm.first_name"
                      type="text"
                      class="normal-input full_width"
                    />
                  </div>
                  <div class="field">
                    <label>Family name prefix</label>
                    <input
                      v-model="row.newPersonForm.prefix"
                      type="text"
                      class="normal-input full_width"
                    />
                  </div>
                  <div class="field">
                    <label>Family name</label>
                    <input
                      v-model="row.newPersonForm.last_name"
                      type="text"
                      class="normal-input full_width"
                    />
                  </div>
                  <div class="field">
                    <label>Family name suffix</label>
                    <input
                      v-model="row.newPersonForm.suffix"
                      type="text"
                      class="normal-input full_width"
                    />
                  </div>
                </div>
                <VBtn
                  color="create"
                  medium
                  :disabled="!row.newPersonForm.last_name"
                  @click="createPerson(row)"
                >
                  Create
                </VBtn>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
    <template #footer>
      <VBtn
        v-if="allExistingMatches"
        color="primary"
        medium
        @click="() => emit('close')"
      >
        Close
      </VBtn>
    </template>
  </Modal>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { People } from '@/routes/endpoints'
import Modal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  authorString: {
    type: String,
    required: true
  },

  existingRoles: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'apply'])

const isLoading = ref(true)
const authorRows = ref([])

const activeRoles = computed(() =>
  props.existingRoles.filter((r) => !r._destroy)
)

const hasSelections = computed(() => {
  return authorRows.value.some(
    (row) => row.selectedPersonId || row.createdPerson
  )
})

const allRowsFilled = computed(() => {
  return authorRows.value.every(
    (row) => row.selectedPersonId || row.createdPerson
  )
})

const allExistingMatches = computed(() => {
  const parsedAuthorCount = authorRows.value.length

  if (activeRoles.value.length !== parsedAuthorCount) {
    return false
  }

  return (
    allRowsFilled.value && authorRows.value.every((row) => row.alreadyExists)
  )
})

onMounted(async () => {
  const parsedAuthors = parseBibtexAuthors(props.authorString)

  authorRows.value = parsedAuthors.map((author, index) => {
    const existingRole = findExistingRoleByIndex(index)

    return {
      originalString: author.originalString,
      parsedFirstName: author.firstName,
      parsedLastName: author.lastName,
      matches: [],
      selectedPersonId: null,
      createdPerson: existingRole ?? null,
      alreadyExists: Boolean(existingRole),
      isSearching: !existingRole,
      newPersonForm: {
        first_name: author.firstName,
        last_name: author.lastName,
        prefix: '',
        suffix: ''
      }
    }
  })

  isLoading.value = false

  for (const row of authorRows.value) {
    if (!row.alreadyExists) {
      await searchMatches(row)
    }
  }
})

function findExistingRoleByIndex(index) {
  const role = activeRoles.value.at(index)

  if (!role) return null

  const person = role.person ?? role

  return {
    id: role.person_id ?? person.id,
    cached:
      role.cached ??
      person.cached ??
      `${person.last_name}, ${person.first_name}`.trim(),
    first_name: person.first_name,
    last_name: person.last_name
  }
}

function parseBibtexAuthors(authorString) {
  if (!authorString) return []

  return authorString.split(/\s+and\s+/i).map((author) => {
    const trimmed = author.trim()

    if (trimmed.includes(',')) {
      const [lastName, firstName = ''] = trimmed.split(',').map((s) => s.trim())

      return {
        originalString: trimmed,
        firstName,
        lastName
      }
    }

    const parts = trimmed.split(/\s+/)

    const lastName = parts.at(-1)
    const firstName = parts.slice(0, -1).join(' ')

    return {
      originalString: trimmed,
      firstName,
      lastName
    }
  })
}

async function searchMatches(row) {
  row.isSearching = true

  try {
    const { body } = await People.where({
      name: row.originalString
    })

    row.matches = body
  } catch {
    row.matches = []
  } finally {
    row.isSearching = false
  }
}

async function createPerson(row) {
  try {
    const { body } = await People.create({
      person: {
        first_name: row.newPersonForm.first_name,
        last_name: row.newPersonForm.last_name,
        prefix: row.newPersonForm.prefix || null,
        suffix: row.newPersonForm.suffix || null
      }
    })

    row.createdPerson = body
    row.selectedPersonId = null

    TW.workbench.alert.create('Person created successfully', 'notice')

    applySelections()
  } catch {}
}

function applySelections() {
  const selectedPeople = []

  for (const row of authorRows.value) {
    if (row.createdPerson) {
      selectedPeople.push(row.createdPerson)
    } else if (row.selectedPersonId) {
      const person = row.matches.find((p) => p.id === row.selectedPersonId)

      if (person) {
        selectedPeople.push(person)
      }
    }
  }

  emit('apply', selectedPeople)
}
</script>

<style scoped>
table {
  border-collapse: collapse;
}

th,
td {
  padding: 8px;
  text-align: left;
  vertical-align: top;
}

th {
  background-color: var(--table-row-bg-odd);
}

td {
  border-bottom: 1px solid var(--border-color);
}

.author-string-cell {
  font-weight: bold;
  white-space: nowrap;
}

.matches-cell {
  min-width: 200px;
}

.matches-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.match-option {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.match-option input[type='radio'] {
  margin: 0;
}

.no-matches {
  color: var(--text-muted-color);
  font-style: italic;
}

.create-cell {
  min-width: 250px;
}

.create-form {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-fields {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.field label {
  font-size: 0.85em;
  color: var(--text-muted-color);
}

.selected-person {
  padding: 8px;
  background-color: var(--badge-blue-bg);
  border-radius: 4px;
}

.selected-text {
  color: var(--badge-blue-color);
}
</style>
