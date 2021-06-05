<template>
  <div class="panel loan-box">
    <div class="header flex-separate middle">
      <h3>Loan information</h3>
      <div class="horizontal-left-content">
        <template v-if="loan.hasOwnProperty('id')">
          <a
            :href="`/loans/${loan.id}`"
            target="_blank"
            class="taxonname separate-right">Show
          </a>
          <button
            @click="showModal = true"
            :disabled="loanItems.length > 0"
            type="button"
            class="button normal-input button-delete separate-left separate-right">Delete loan
          </button>
        </template>
        <expand
          class="separate-left"
          v-model="displayBody"/>
      </div>
    </div>
    <modal
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Confirm delete</h3>
      <div slot="body">Are you sure you want to delete <span v-html="loan.object_tag"/>?</div>
      <div slot="footer">
        <button
          @click="deleteLoan()"
          type="button"
          class="normal-input button button-delete align-end">Delete
        </button>
      </div>
    </modal>
    <div
      class="body horizontal-left-content align-start"
      v-if="displayBody">
      <div class="column-left">
        <span><b>Lender</b></span>
        <hr>
        <div class="field">
          <label>Lender address</label>
          <textarea v-model="loan.lender_address"/>
        </div>
        <div class="field">
          <label>Request method</label>
          <input
            v-model="loan.request_method"
            type="text"
            class="normal-input">
        </div>
        <div class="field">
          <label>Date requested</label>
          <input
            v-model="loan.date_requested"
            type="date"
            class="normal-input">
        </div>
        <div class="field">
          <label>Date sent</label>
          <input
            v-model="loan.date_sent"
            type="date"
            class="normal-input">
        </div>
        <div class="field">
          <label>Date received</label>
          <input
            v-model="loan.date_received"
            type="date"
            class="normal-input">
        </div>
        <div class="field">
          <label>Date return expected</label>
          <input
            v-model="loan.date_return_expected"
            type="date"
            class="normal-input">
        </div>
        <div class="field">
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

      <div class="column-right">
        <span><b>Recipient</b></span>
        <hr>
        <label>People</label>
        <role-picker
          v-model="rolesRecipient"
          role-type="LoanRecipient"/>
        <div class="horizontal-left-content">
          <div class="separate-right">
            <div class="field">
              <label>Honorific</label>
              <input
                v-model="loan.recipient_honorific"
                type="text"
                class="normal-input">
            </div>
            <div class="field">
              <label>Address</label>
              <textarea
                v-model="loan.recipient_address"
                type="text"/>
            </div>
          </div>
          <div class="separate-left">
            <div class="field">
              <label>Email </label>
              <input
                v-model="loan.recipient_email"
                type="text"
                class="normal-input">
            </div>
            <div class="field">
              <label>Phone</label>
              <input
                v-model="loan.recipient_phone"
                type="text"
                class="normal-input">
            </div>
            <div class="field">
              <label>Country</label>
              <input
                v-model="loan.recipient_country"
                type="text"
                class="normal-input">
            </div>
          </div>
        </div>
        <p><b>Supervisor</b></p>
        <hr>
        <role-picker
          v-model="rolesSupervisor"
          role-type="LoanSupervisor"/>
        <div class="field">
          <label>Email</label>
          <input
            v-model="loan.supervisor_email"
            type="text"
            class="normal-input">
        </div>
        <div class="field">
          <label>Phone</label>
          <input
            v-model="loan.supervisor_phone"
            type="text"
            class="normal-input">
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  import rolePicker from 'components/role_picker.vue'
  import modal from 'components/ui/Modal.vue'
  import expand from './expand.vue'
  import ActionNames from '../store/actions/actionNames'
  import { GetterNames } from '../store/getters/getters'
  import { updateLoan, destroyLoan } from '../request/resources'

  export default {
    components: {
      rolePicker,
      expand,
      modal
    },
    computed: {
      loanItems() {
        return this.$store.getters[GetterNames.GetLoanItems]
      },
      getLoan: {
        get() {
          return this.$store.getters[GetterNames.GetLoan]
        }
      },
      rolesRecipient: {
        get() {
          return this.loan.loan_recipient_roles
        },
        set(value) {
          this.roles_recipient = value
        }
      },
      rolesSupervisor: {
        get() {
          return this.loan.loan_supervisor_roles
        },
        set(value) {
          this.roles_supervisor = value
        }
      }
    },
    data: function () {
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
      getLoan: function () {
        this.loan = this.getLoan
      }
    },
    methods: {
      update() {
        this.loan.roles_attributes = this.roles_recipient.concat(this.roles_supervisor)
        updateLoan({loan: this.loan}).then(response => {
          TW.workbench.alert.create('Loan was successfully updated.', 'notice')
        })
      },
      create() {
        this.loan.roles_attributes = this.roles_recipient.concat(this.roles_supervisor)
        this.$store.dispatch(ActionNames.CreateLoan, this.loan)
      },
      deleteLoan() {
        destroyLoan(this.loan.id).then(response => {
          window.location.href = '/tasks/loans/edit_loan/'
        })
      }
    }
  }
</script>

<style lang="scss">
  #edit_loan_task {
    .column-left {
      width: 40%;
    }
    .column-right {
    }
    textarea {
      header: 80px;
      min-height: 80px;
    }
  }
</style>
