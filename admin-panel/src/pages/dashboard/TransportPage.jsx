import { Bus } from 'lucide-react'
import CategoryPageTemplate from '../../components/CategoryPageTemplate'

export default function TransportPage() {
  return (
    <CategoryPageTemplate
      category="transport"
      title="Transport Management"
      description="Manage bus, train, and flight bookings and operators."
      icon={Bus}
      themeColor="#BB8A52"
      showTypeFilter={true}
      typeOptions={[
        { value: 'bus', label: 'Bus' },
        { value: 'train', label: 'Train' },
        { value: 'flight', label: 'Flights' },
      ]}
      statLabels={{
        label1: 'Transport Types',
      }}
    />
  )
}