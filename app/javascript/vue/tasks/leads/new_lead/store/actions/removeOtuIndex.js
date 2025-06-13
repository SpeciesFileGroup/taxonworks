import { LeadItem } from '@/routes/endpoints'

export default function removeOtuIndex(childIndex, otuIndex) {
  const payload = {
    lead_id: this.children[childIndex].id,
    otu_id: this.lead_item_otus.parent[otuIndex].id,
  }

  this.setLoading(true)
  LeadItem.removeOtuIndex(payload)
    .then(({ body }) => {
      this.lead_item_otus = body.lead_item_otus
      this.print_key = body.print_key
    })
    .catch(() => {})
    .finally(() => { this.setLoading(false) })
}