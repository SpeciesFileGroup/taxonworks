<template>
  <BlockLayout>
    <template #header>
      <h3>Loan information</h3>
    </template>
    <template #options>
      <ul class="no_bullets context-menu">
        <li>
          <a
            v-if="loan.id"
            :href="`/loans/${loan.id}/recipient_form`">
            Recipient form
          </a>
        </li>
        <li>
          <a
            v-if="loan.id"
            :href="`/loans/${loan.id}`"
            target="_blank"
            class="taxonname separate-right">
            Show
          </a>
        </li>
      </ul>
      <button
        v-if="loan.id"
        @click="showModal = true"
        :disabled="loanItems.length > 0"
        type="button"
        class="button normal-input button-delete separate-left separate-right">
        Delete loan
      </button>
      <expand
        class="separate-left"
        v-model="displayBody"/>
    </template>
    <template #body>
      <modal
        v-if="showModal"
        @close="showModal = false">
        <template #header>
          <h3>Confirm delete</h3>
        </template>
        <template #body>
          <div>Are you sure you want to delete <span v-html="loan.object_tag"/>?</div>
        </template>
        <template #footer>
          <button
            @click="deleteLoan()"
            type="button"
            class="normal-input button button-delete">Delete
          </button>
        </template>
      </modal>
      <div
        class="body horizontal-left-content align-start loan-information"
        v-if="displayBody">
        <div>
          <span><b>Lender</b></span>
          <hr>
          <div class="field label-above">
            <label>Lender address</label>
            <textarea
              class="full_width"
              v-model="loan.lender_address"
              rows="5"
            />
          </div>
          <div class="field label-above">
            <label>Request method</label>
            <input
              v-model="loan.request_method"
              type="text"
              class="normal-input full_width">
          </div>
          <div class="field label-above">
            <label>Date requested</label>
            <input
              v-model="loan.date_requested"
              type="date"
              class="normal-input">
          </div>
          <div class="field label-above">
            <label>Date sent</label>
            <input
              v-model="loan.date_sent"
              type="date"
              class="normal-input">
          </div>
          <div class="field label-above">
            <label>Date received</label>
            <input
              v-model="loan.date_received"
              type="date"
              class="normal-input">
          </div>
          <div class="field label-above">
            <label>Date return expected</label>
            <input
              v-model="loan.date_return_expected"
              type="date"
              class="normal-input">
          </div>
          <div class="field label-above">
            <label>Date closed</label>
            <input
              v-model="loan.date_closed"
              type="date"
              class="normal-input">
          </div>
          <div>
            <template v-if="loan.hasOwnProperty('id')">
              <button
                @click="update()"
                type="button"
                class="button normal-input button-submit">Update Loan
              </button>
            </template>
            <button
              @click="create()"
              v-else
              type="button"
              class="button normal-input button-submit">Create Loan
            </button>
          </div>
        </div>

        <div>
          <span><b>Recipient</b></span>
          <hr>
          <div class="field">
            <label>People</label>
            <role-picker
              v-model="rolesRecipient"
              role-type="LoanRecipient"/>
          </div>
          <div class="horizontal-left-content align-start full_width">
            <div class="separate-right full_width">
              <div class="field label-above">
                <label>Honorific</label>
                <input
                  v-model="loan.recipient_honorific"
                  type="text"
                  class="normal-input full_width">
              </div>
              <div class="field label-above">
                <label>Address</label>
                <textarea
                  class="full_width"
                  rows="5"
                  v-model="loan.recipient_address"
                  type="text" />
              </div>
            </div>
            <div class="full_width">
              <div class="field label-above">
                <label>Email</label>
                <input
                  v-model="loan.recipient_email"
                  type="text"
                  class="normal-input full_width">
              </div>
              <div class="field label-above">
                <label>Phone</label>
                <input
                  v-model="loan.recipient_phone"
                  type="text"
                  class="normal-input full_width">
              </div>
              <div class="field label-above">
                <label>Country</label>
                <input
                  v-model="loan.recipient_country"
                  type="text"
                  class="normal-input full_width">
              </div>
            </div>
          </div>
          <p><b>Supervisor</b></p>
          <hr>
          <div class="field">
            <role-picker
              v-model="rolesSupervisor"
              role-type="LoanSupervisor"/>
          </div>
          <div class="field label-above">
            <label>Email</label>
            <input
              v-model="loan.supervisor_email"
              type="text"
              class="normal-input">
          </div>
          <div class="field label-above">
            <label>Phone</label>
            <input
              v-model="loan.supervisor_phone"
              type="text"
              class="normal-input">
          </div>
        </div>
      </div>
    </template>
  </BlockLayout>
</template>

<script>

import RolePicker from 'components/role_picker.vue'
import Modal from 'components/ui/Modal.vue'
import Expand from './expand.vue'
import ActionNames from '../store/actions/actionNames'
import BlockLayout from 'components/layout/BlockLayout.vue'
import { GetterNames } from '../store/getters/getters'
import { Loan } from 'routes/endpoints'

export default {
  components: {
    RolePicker,
    Expand,
    Modal,
    BlockLayout
  },

  computed: {
    loanItems () {
      return this.$store.getters[GetterNames.GetLoanItems]
    },

    getLoan: {
      get() {
        return this.$store.getters[GetterNames.GetLoan]
      }
    },

    rolesRecipient: {
      get () {
        return this.loan.loan_recipient_roles
      },
      set (value) {
        this.roles_recipient = value
      }
    },

    rolesSupervisor: {
      get () {
        return this.loan.loan_supervisor_roles
      },
      set (value) {
        this.roles_supervisor = value
      }
    }
  },

  data () {
    return {
      showModal: false,
      displayBody: true,
      roles_supervisor: [],
      roles_recipient: [],
      loan: {
        loan_recipient_roles: [],
        roles_attributes: [],
        date_requested: undefined,
        request_method: undefined,
        date_sent: undefined,
        date_received: undefined,
        date_return_expected: undefined,
        recipient_person_id: undefined,
        recipient_address: undefined,
        recipient_email: undefined,
        recipient_phone: undefined,
        recipient_country: undefined,
        supervisor_person_id: undefined,
        supervisor_email: undefined,
        supervisor_phone: undefined,
        date_closed: undefined,
        recipient_honorific: undefined,
        lender_address: undefined,
        clone_from: undefined
      }
    }
  },

  watch: {
    getLoan () {
      this.loan = this.getLoan
    }
  },

  methods: {
    update () {
      this.loan.roles_attributes = this.roles_recipient.concat(this.roles_supervisor)
      Loan.update(this.loan.id, { loan: this.loan }).then(() => {
        TW.workbench.alert.create('Loan was successfully updated.', 'notice')
      })
    },

    create () {
      this.loan.roles_attributes = this.roles_recipient.concat(this.roles_supervisor)
      this.$store.dispatch(ActionNames.CreateLoan, this.loan)
    },

    deleteLoan () {
      Loan.destroy(this.loan.id).then(() => {
        window.location.href = '/tasks/loans/edit_loan/'
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.loan-information {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1em;
}
</style>
