import { Lead } from '@/routes/endpoints'

export default function addOtuIndex(child_index, otu_index) {
  const payload = {
    lead_id: this.children[child_index].id,
    otu_id: this.lead_item_otus.parent[otu_index].id
  }

  this.setLoading(true)
  Lead.add_otu_index(payload)
    .then(({ body }) => {
      this.lead_item_otus = body.lead_item_otus
    })
    .catch(() => {})
    .finally(() => { this.setLoading(false) })
}