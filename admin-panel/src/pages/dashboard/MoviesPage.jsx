import { Film } from 'lucide-react'
import CategoryPageTemplate from '../../components/CategoryPageTemplate'

export default function MoviesPage() {
  return (
    <CategoryPageTemplate
      category="movies"
      title="Movies Management"
      description="View and manage all movie bookings and analytics."
      icon={Film}
      themeColor="#6D9773"
      statLabels={{
        label1: 'Total Movies',
      }}
    />
  )
}