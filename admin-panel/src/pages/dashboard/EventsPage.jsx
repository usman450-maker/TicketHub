import { Calendar } from 'lucide-react'
import CategoryPageTemplate from '../../components/CategoryPageTemplate'

export default function EventsPage() {
  return (
    <CategoryPageTemplate
      category="events"
      title="Events Management"
      description="Manage concerts, shows, exhibitions and event bookings."
      icon={Calendar}
      themeColor="#B5CBB9"
      statLabels={{
        label1: 'Total Events',
      }}
    />
  )
}