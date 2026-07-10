import { TreePine } from 'lucide-react'
import CategoryPageTemplate from '../../components/CategoryPageTemplate'

export default function ParksPage() {
  return (
    <CategoryPageTemplate
      category="parks"
      title="Parks Management"
      description="Manage theme parks, tickets and visitor bookings."
      icon={TreePine}
      themeColor="#F59E0B"
      statLabels={{
        label1: 'Total Parks',
      }}
    />
  )
}