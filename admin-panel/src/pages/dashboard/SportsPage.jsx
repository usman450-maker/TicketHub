import { Trophy } from 'lucide-react'
import CategoryPageTemplate from '../../components/CategoryPageTemplate'

export default function SportsPage() {
  return (
    <CategoryPageTemplate
      category="sports"
      title="Sports Management"
      description="Manage sports matches, tournaments and stadium bookings."
      icon={Trophy}
      themeColor="#0C3B2E"
      statLabels={{
        label1: 'Total Matches',
      }}
    />
  )
}